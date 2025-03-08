//
//  CardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI
import SwiftData

struct CardLinkDestinationView: View {
    let cardLinkDestinationValue: CardLinkDestinationValue
    
    var body: some View {
        CardView(cardID: cardLinkDestinationValue.cardID)
            .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CardView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var model: CardViewModel
    
    @Query
    private var history: [History]
    
    private var latestReleaseInfo: String? {
        if let products = model.card?.getProducts(), !products.isEmpty && products.count > 1 {
            let elapsedDays = products[0].productReleaseDate.timeIntervalSinceNow()
            if elapsedDays < 0 {
                return "\(elapsedDays.decimal) day(s) until next printing"
            } else {
                return "\(elapsedDays.decimal) day(s) since last printing"
            }
        }
        return nil
    }
    
    private var initialReleaseInfo: String {
        if let products = model.card?.getProducts(), !products.isEmpty {
            let elapsedDays = products.last!.productReleaseDate.timeIntervalSinceNow()
            if elapsedDays < 0 {
                return "\(elapsedDays.decimal) day(s) till card debuts"
            } else {
                return "\(elapsedDays.decimal) day(s) since initial printing"            }
        }
        return "No products currently in DB have printed this card"
    }
    
    init(cardID: String) {
        self.model = .init(cardID: cardID)
        
        _history = Query(
            filter: #Predicate<History> { h in
                h.id == cardID
            }, sort: [SortDescriptor(\.timesAccessed, order: .reverse)])
    }
    
    var body: some View {
        VStack {
            if model.requestErrors[.card, default: nil] == nil {
                TabView {
                    Tab("Info", systemImage: "info.circle.fill") {
                        ScrollView {
                            YGOCardView(cardID: model.cardID, card: model.card)
                                .equatable()
                                .padding(.bottom)
                            
                            if let card = model.card {
                                SectionView(header: "Releases",
                                            variant: .plain,
                                            content: {
                                    VStack(alignment: .leading) {
                                        if !card.getProducts().isEmpty {
                                            Text("Rarities")
                                                .font(.headline)
                                            Text("All the different rariites \(card.cardName) was printed in")
                                                .font(.callout)
                                            OneDBarChartView(data: card.getRarityDistribution()
                                                .map { ChartData(category: $0.key, count: $0.value) }
                                            )
                                            Divider()
                                                .padding(.vertical)
                                        }
                                        
                                        Label(initialReleaseInfo, systemImage: "1.circle")
                                            .font(.callout)
                                            .padding(.bottom, 2)
                                        if let latestReleaseInfo {
                                            Label(latestReleaseInfo, systemImage: "calendar")
                                                .font(.callout)
                                        }
                                        
                                    }
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                })
                                .modifier(ParentViewModifier())
                                
                                RelatedContentView(
                                    cardID: card.cardID,
                                    cardName: card.cardName,
                                    cardColor: card.cardColor,
                                    products: card.getProducts(),
                                    tcgBanLists: card.getBanList(format: BanListFormat.tcg),
                                    mdBanLists: card.getBanList(format: BanListFormat.md)
                                )
                                .modifier(ParentViewModifier())
                                .padding(.bottom, 50)
                            } else {
                                ProgressView("Loading...")
                                    .controlSize(.large)
                            }
                        }
                    }
                    
                    Tab("Suggestions", systemImage: "sparkles") {
                        CardSuggestionsView(model: model)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
        .navigationTitle(model.card?.cardName ?? "")
        .frame(maxWidth:.infinity, maxHeight: .infinity)
        .overlay {
            if let networkError = model.requestErrors[.card, default: nil] {
                switch networkError {
                case .badRequest, .unprocessableEntity:
                    ContentUnavailableView("Card not currently supported",
                                           systemImage: "exclamationmark.square.fill",
                                           description: Text("Please check back later"))
                default:
                    NetworkErrorView(error: networkError, action: {
                        Task {
                            model.resetCardError()
                            await model.fetchCardData(forceRefresh: true)
                        }
                    })
                }
            }
        }
        .task {
            await model.fetchCardData()
        }
        .onChange(of: model.card) {
            Task {
                let newItem = History(resource: .card, id: model.cardID, timesAccessed: 1)
                newItem.updateHistoryContext(history: history, modelContext: modelContext)
            }
        }
    }
}

#Preview("Kluger")  {
    CardView(cardID: "90307498")
}

#Preview("Token")  {
    CardView(cardID: "0034")
}

#Preview("Card DNE")  {
    CardView(cardID: "12345678")
}
