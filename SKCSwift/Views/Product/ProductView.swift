//
//  ProductView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/5/24.
//

import SwiftUI

struct ProductLinkDestinationView: View {
    let productLinkDestinationValue: ProductLinkDestinationValue
    
    var body: some View {
        ProductView(productID: productLinkDestinationValue.productID)
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProductView: View {
    @State var model: ProductViewModel
    
    init(productID: String) {
        self.model = .init(productID: productID)
    }
    
    var body: some View {
        TabView {
            Tab("Info", systemImage: "info.circle.fill") {
                ScrollView {
                    if model.requestErrors[.product, default: nil] == nil {
                        ProductInfoView(productID: model.productID, product: model.product)
                    }
                }
                .scrollDisabled(model.requestErrors[.product, default: nil] != nil)
                .task(priority: .userInitiated) {
                    await model.fetchProductData()
                }
            }
            
            Tab("Suggestions", systemImage: "sparkles") {
                ProductCardSuggestionsView(model: model)
            }
        }
        .navigationTitle(model.product?.productName ?? "")
        .frame(maxWidth:.infinity, maxHeight: .infinity)
        .overlay {
            if let networkError = model.requestErrors[.product, default: nil] {
                NetworkErrorView(error: networkError, action: {
                    Task{
                        model.resetProductError()
                        await model.fetchProductData(forceRefresh: true)
                    }
                }
                )
                .padding(.top, 20)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

private struct ProductInfoView: View {
    let productID: String
    let product: Product?
    
    @State private var showStats = false
    
    var body: some View {
        VStack{
            ProductImageView(width: 150, productID: productID, imgSize: .small)
                .padding(.vertical)
            if let product = product, let contents = product.productContent {
                Text([product.productId, product.productType, product.productSubType].joined(separator: " | "))
                    .font(.headline)
                InlineDateView(date: product.productReleaseDate)
                
                Button {
                    showStats = true
                } label: {
                    Label("Metrics", systemImage: "chart.bar.fill")
                        .frame(width: 200)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .sheet(isPresented: $showStats, onDismiss: {showStats = false}) {
                    ProductStatsView(productID: product.productId, productName: product.productName, rarities: contents.flatMap { $0.rarities }, cards: contents.compactMap { $0.card })
                }
                .padding(.bottom)
                
                if let contents = product.productContent {
                    ProductContentView(productID: productID, contents: contents)
                }
            } else {
                ProgressView("Loading...")
                    .controlSize(.large)
            }
        }
        .modifier(ParentViewModifier(alignment: .center))
        .padding(.bottom, 40)
    }
}

private struct ProductStatsView: View {
    let productID: String
    let productName: String
    
    private let rarityData: [ChartData]
    private let mstData: [ChartData]
    private let monsterColorData: [ChartData]
    private let monsterAttributeData: [ChartData]
    
    init(productID: String, productName: String, rarities: [String], cards: [Card]) {
        self.productID = productID
        self.productName = productName
        
        rarityData = rarities
            .reduce(into: [String: Int]()) { counts, rarity in
                counts[rarity.cardRarityShortHand(), default: 0] += 1
            }
            .map { ChartData(name: $0.key, count: $0.value) }
        
        mstData = cards
            .reduce(into: [String: Int]()) { counts, card in
                if card.attribute == .spell || card.attribute == .trap {
                    counts[card.attribute.rawValue, default: 0] += 1
                } else {
                    counts["Monster", default: 0] += 1
                }
            }
            .map { ChartData(name: $0.key, count: $0.value) }
        
        monsterColorData = cards
            .filter { $0.attribute != .spell && $0.attribute != .trap }
            .map { $0.cardColor.replacingOccurrences(of: "-", with: " ") }
            .reduce(into: [String: Int]()) { counts, color in
                counts[color, default: 0] += 1
            }
            .map { ChartData(name: $0.key, count: $0.value) }
        
        monsterAttributeData = cards
            .filter { $0.attribute != .spell && $0.attribute != .trap }
            .reduce(into: [String: Int]()) { counts, card in
                counts[card.cardAttribute!, default: 0] += 1
            }
            .map { ChartData(name: $0.key, count: $0.value) }
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
            .modifier(ParentViewModifier())
        }
    }
}

private struct ProductContentView: View {
    let productID: String
    let contents: [ProductContent]
    
    var body: some View {
        LazyVStack {
            ForEach(contents) { content in
                if let card = content.card {
                    NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
                        GroupBox(label: Label("\(productID)-\(content.productPosition)", systemImage: "number.circle.fill").font(.subheadline)) {
                            CardListItemView(card: card, showAllInfo: true)
                                .equatable()
                            
                            FlowLayout(spacing: 6) {
                                ForEach(content.rarities, id: \.self) { rarity in
                                    Text(rarity.cardRarityShortHand())
                                        .modifier(TagModifier())
                                }
                            }
                        }
                        .groupBoxStyle(.listItem)
                    })
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ProductView(productID: "LEDE")
}
