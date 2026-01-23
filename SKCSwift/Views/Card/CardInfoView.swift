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
                
                if model.cardDTS == .done {
                    LazyVStack {
                        SuggestionsView(
                            subjectID: model.cardID,
                            subjectName: model.card?.cardName ?? "",
                            subjectType: .card,
                            areSuggestionsLoaded: model.areSuggestionsLoaded,
                            hasSuggestions: model.hasSuggestions(),
                            hasError: model.suggestionsError != nil,
                            namedMaterials: model.namedMaterials ?? [],
                            namedReferences: model.namedReferences ?? [],
                            referencedBy: model.referencedBy ?? [],
                            materialFor: model.materialFor ?? []
                        )
                        .equatable()
                        .task {
                            await model.fetchAllSuggestions()
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

#Preview("Token")  {
    CardInfoView(cardID: "0034")
}

#Preview("Card DNE")  {
    CardInfoView(cardID: "12345678")
}
