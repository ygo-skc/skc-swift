//
//  CardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI
import SwiftData
import YGOService

struct CardInfoView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var model: CardViewModel
    
    @Query
    private var cardFromTable: [History]
    
    init(cardID: String) {
        self.model = .init(cardID: cardID)
        _cardFromTable = Query(ArchiveContainer.fetchHistoryResourceByID(id: cardID))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                if model.cardDTS != .error {
                    VStack(spacing: 30) {
                        YGOCardView(cardID: model.cardID, card: model.card, width: UIScreen.main.bounds.width)
                            .equatable()
                        
                        if let card = model.card, let products = model.products {
                            CardReleasesView(card: card, products: products)
                                .modifier(.parentView)
                            CardRestrictionsView(card: card,
                                                 tcgBanList: model.restrictions?.TCG ?? [],
                                                 mdBanLists: model.restrictions?.MD ?? [],
                                                 score: model.score)
                            .modifier(.parentView)
                        }
                    }
                }
                
                if model.cardDTS == .done, let cardName = model.card?.cardName {
                    LazyVStack(alignment: .leading, spacing: 25) {
                        Label("Suggestions", systemImage: "sparkles")
                            .font(.title)
                            .task {
                                await model.fetchAllSuggestions()
                            }
                        
                        if model.areSuggestionsLoaded && model.suggestionsError == nil {
                            SuggestionSectionView(header: "Named Materials",
                                                  subHeader: "Cards that can be used as summoning material for **\(cardName)**.",
                                                  references: model.namedMaterials ?? [],
                                                  variant: .suggestion)
                            SuggestionSectionView(header: "Named References",
                                                  subHeader: "Cards found in the text of **\(cardName)** but aren't explicitly listed as a summoning material.",
                                                  references: model.namedReferences ?? [],
                                                  variant: .suggestion)
                            SuggestionSectionView(header: "Material For",
                                                  subHeader: "ED cards that can be summoned using **\(cardName)** as material",
                                                  references: model.materialFor ?? [],
                                                  variant: .support)
                            SuggestionSectionView(header: "Referenced By",
                                                  subHeader: "Cards that reference **\(cardName)** excluding ED cards that reference **\(model.card?.cardName ?? "")** as a summoning material.",
                                                  references: model.referencedBy ?? [],
                                                  variant: .support)
                        }
                        
                        SuggestionOverlayView(areSuggestionsLoaded: model.areSuggestionsLoaded,
                                              noSuggestionsFound: !model.hasSuggestions(),
                                              networkError: model.suggestionsError,
                                              action: {
                            Task {
                                await model.fetchAllSuggestions(forceRefresh: true)
                            }
                        })
                        .equatable()
                    }
                    .modifier(.parentView)
                }
            }
        }
        .frame(maxWidth:.infinity, maxHeight: .infinity)
        .scrollDisabled(model.cardDTS == .error)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(model.card?.cardName ?? "Loading…")
        .task {
            await model.fetchCardInfo()
        }
        .onChange(of: model.card) {
            Task {
                let newItem = History(resource: .card, id: model.cardID, timesAccessed: 1)
                newItem.updateHistoryContext(history: cardFromTable, modelContext: modelContext)
            }
        }
        .overlay {
            if let networkError = model.cardNE {
                switch networkError {
                case .badRequest, .unprocessableEntity:
                    ContentUnavailableView("Card not currently supported",
                                           systemImage: "exclamationmark.square.fill",
                                           description: Text("Please check back later"))
                default:
                    NetworkErrorView(error: networkError, action: {
                        Task {
                            await model.fetchCardInfo(forceRefresh: true)
                        }
                    })
                }
            }
        }
    }
}

#Preview("Kluger")  {
    CardInfoView(cardID: "90307498")
}

#Preview("Air Neos")  {
    CardInfoView(cardID: "11502550")
}

#Preview("No Suggestions")  {
    CardInfoView(cardID: "61269611")
}

#Preview("Token")  {
    CardInfoView(cardID: "0034")
}

#Preview("Card DNE")  {
    CardInfoView(cardID: "12345678")
}
