//
//  ProductView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/5/24.
//

import SwiftUI
import SwiftData

struct ProductLinkDestinationView: View {
    let productLinkDestinationValue: ProductLinkDestinationValue
    
    var body: some View {
        ProductView(productID: productLinkDestinationValue.productID)
            .navigationBarTitleDisplayMode(.automatic)
    }
}

private struct ProductView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var model: ProductViewModel
    
    @Query
    private var productFromTable: [History]
    
    init(productID: String) {
        self.model = .init(productID: productID)
        _productFromTable = Query(ArchiveContainer.fetchHistoryResourceByID(id: productID))
    }
    
    var body: some View {
        ProductDetailsView(productID: model.productID,
                           product: model.product,
                           productDTS: model.productDTS,
                           productNE: model.productNE,
                           retryCB: { await model.fetchProductData(forceRefresh: true) },
                           suggestions: {
            SuggestionsParentView(isScrollDisabled: model.suggestionsNE != nil
                                  || model.suggestionsDTS != .done
                                  || !model.hasSuggestions,
                                  dataCB: { forceRefresh in
                await model.fetchProductSuggestions(forceRefresh: true)
            }, suggestionsView: {
                SuggestionsView(
                    subjectID: model.productID,
                    subjectName: model.product?.productName ?? "",
                    subjectType: .product,
                    areSuggestionsLoaded: model.suggestionsDTS == .done,
                    hasSuggestions: model.hasSuggestions,
                    hasError: model.suggestionsNE != nil,
                    namedMaterials: model.suggestions?.suggestions.namedMaterials ?? [],
                    namedReferences: model.suggestions?.suggestions.namedReferences ?? [],
                    referencedBy: model.suggestions?.support.referencedBy ?? [],
                    materialFor: model.suggestions?.support.materialFor ?? []
                )
                .equatable()
            }, overlayView: {
                SuggestionOverlayView(areSuggestionsLoaded: model.suggestionsDTS == .done,
                                      noSuggestionsFound: !model.hasSuggestions,
                                      networkError: model.suggestionsNE,
                                      action: {
                    Task {
                        await model.fetchProductSuggestions(forceRefresh: true)
                    }
                })
                .equatable()
            })
        })
        .equatable()
        .navigationTitle(model.product?.productName ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await model.fetchProductData()
        }
        .onChange(of: model.product) {
            Task {
                let newItem = History(resource: .product, id: model.productID, timesAccessed: 1)
                newItem.updateHistoryContext(history: productFromTable, modelContext: modelContext)
            }
        }
    }
    
    private struct ProductDetailsView<Suggestions: View>: View, Equatable {
        static func == (lhs: ProductView.ProductDetailsView<Suggestions>, rhs: ProductView.ProductDetailsView<Suggestions>) -> Bool {
            lhs.productDTS == rhs.productDTS && lhs.productNE == rhs.productNE
        }
        
        let productID: String
        let product: Product?
        let productDTS: DataTaskStatus
        let productNE: NetworkError?
        let retryCB: () async -> Void
        
        @ViewBuilder let suggestions: () -> Suggestions
        
        var body: some View {
            TabView {
                Tab("Info", systemImage: "info.circle.fill") {
                    if productNE == nil {
                        ScrollView {
                            VStack{
                                ProductStatsView(productID: productID, product: product)
                                if let product = product, let productContents = product.productContent {
                                    CardListView(cards: productContents.filter({ $0.card != nil }).map({ $0.card! }), label: { ind in
                                        Label("\(productID)-\(productContents[ind].productPosition)", systemImage: "number.circle.fill").font(.subheadline)
                                    }) { ind in
                                        FlowLayout(spacing: 6) {
                                            ForEach(productContents[ind].rarities, id: \.self) { rarity in
                                                Text(rarity.cardRarityShortHand())
                                                    .modifier(TagModifier())
                                            }
                                        }
                                    }
                                }
                            }
                            .modifier(.centeredParentView)
                            .padding(.bottom, 40)
                        }
                        .scrollDisabled(productDTS != .done)
                    }
                }
                
                Tab("Suggestions", systemImage: "sparkles") {
                    if productDTS == .done {
                        suggestions()
                    }
                }
            }
            .frame(maxWidth:.infinity, maxHeight: .infinity)
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .overlay {
                if DataTaskStatusParser.isDataPending(productDTS) {
                    ProgressView("Loading...")
                        .controlSize(.large)
                } else if let productNE {
                    NetworkErrorView(error: productNE, action: {
                        Task{
                            await retryCB()
                        }
                    })
                }
            }
        }
    }
}

private struct ProductStatsView: View  {
    let productID: String
    let product: Product?
    
    @State private var chartData: ([ChartData], [ChartData], [ChartData], [ChartData])?
    @State private var showStats = false
    
    @concurrent
    nonisolated func productData(productContents: [ProductContent]) async -> ([ChartData], [ChartData], [ChartData], [ChartData]) {
        return await Task.detached {
            let rarities = productContents.flatMap { $0.rarities }
            let cards = productContents.compactMap { $0.card }
            
            let rarityData = rarities
                .reduce(into: [String: Int]()) { counts, rarity in
                    counts[rarity.cardRarityShortHand(), default: 0] += 1
                }
                .map { ChartData(category: $0.key, count: $0.value) }
            
            let mstData = cards
                .reduce(into: [String: Int]()) { counts, card in
                    if card.attribute == .spell || card.attribute == .trap {
                        counts[card.attribute.rawValue, default: 0] += 1
                    } else {
                        counts["Monster", default: 0] += 1
                    }
                }
                .map { ChartData(category: $0.key, count: $0.value) }
            
            let monsterColorData = cards
                .filter { $0.attribute != .spell && $0.attribute != .trap }
                .map { $0.cardColor.replacingOccurrences(of: "-", with: " ") }
                .reduce(into: [String: Int]()) { counts, color in
                    counts[color, default: 0] += 1
                }
                .map { ChartData(category: $0.key, count: $0.value) }
            
            let monsterAttributeData = cards
                .filter { $0.attribute != .spell && $0.attribute != .trap }
                .reduce(into: [String: Int]()) { counts, card in
                    counts[card.cardAttribute!, default: 0] += 1
                }
                .map { ChartData(category: $0.key, count: $0.value) }
            
            return (rarityData, mstData, monsterColorData, monsterAttributeData)
        }.value
    }
    
    var body: some View {
        HStack(alignment: .top) {
            ProductImageView(width: 150, productID: productID, imgSize: .small)
            
            VStack(alignment: .leading) {
                if let product = product, let productContents = product.productContent {
                    InlineDateView(date: product.productReleaseDate)
                        .padding(.bottom, 3)
                    
                    FlowLayout(spacing: 10) {
                        Group {
                            Label(product.productId, systemImage: "number")
                            Label(product.productType, systemImage: "tag")
                            Label(product.productSubType, systemImage: "tag")
                            Label("\(product.productTotal!) card(s)", systemImage: "tray.full.fill")
                        }
                        .modifier(TagModifier(font: .caption))
                    }
                    .padding(.bottom)
                    
                    Button {
                        showStats = true
                        if chartData == nil {
                            Task {
                                await chartData = productData(productContents: productContents)
                            }
                        }
                    } label: {
                        Label("Metrics", systemImage: "chart.bar.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .sheet(isPresented: $showStats, onDismiss: {showStats = false}) {
                        if let data = chartData {
                            ProductMetricsView(productID: product.productId, productName: product.productName, data: data)
                        } else {
                            ProgressView("Loading...")
                                .controlSize(.large)
                        }
                    }
                    .padding(.bottom)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom)
    }
    
    private struct ProductMetricsView: View {
        let productID: String
        let productName: String
        
        private let rarityData: [ChartData]
        private let mstData: [ChartData]
        private let monsterColorData: [ChartData]
        private let monsterAttributeData: [ChartData]
        
        init(productID: String, productName: String, data: ([ChartData], [ChartData], [ChartData], [ChartData])) {
            self.productID = productID
            self.productName = productName
            (rarityData, mstData, monsterColorData, monsterAttributeData) = data
        }
        
        var body: some View {
            ScrollView {
                VStack {
                    Label {
                        Text("Metrics")
                            .font(.title)
                    } icon: {
                        ProductImageView(width: 50, productID: productID, imgSize: .tiny)
                    }
                    .padding(.bottom)
                    
                    PieChartGroupView(
                        description: "Distribution of all cards printed in **\(productName)** and their unique rarities. In some cases, cards might have multiple rarities (e.g. common, rare, etc).",
                        dataTitle: "Rarity Distribution", data: rarityData)
                    PieChartGroupView(
                        description: "Cards printed in **\(productName)** categorized into three main types: Monster, Spell, and Trap.",
                        dataTitle: "M/S/T Distribution", data: mstData)
                    PieChartGroupView(
                        description: "Monster cards printed in **\(productName)** categorized into their respective card color.",
                        dataTitle: "Monster Color", data: monsterColorData)
                    PieChartGroupView(
                        description: "Monster cards printed in **\(productName)** categorized by their attribute.",
                        dataTitle: "Monster Attribute", data: monsterAttributeData)
                }
                .modifier(.parentView)
            }
        }
    }
}

#Preview("Legacy of Destruction") {
    ProductView(productID: "LEDE")
}

#Preview("TP5 - No Suggestions") {
    ProductView(productID: "TP5")
}

#Preview("Product DNE") {
    ProductView(productID: "JAVI")
}
