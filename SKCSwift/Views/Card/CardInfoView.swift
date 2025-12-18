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
        CardDetailsView(cardID: model.cardID,
                        card: model.card,
                        products: model.products,
                        tcgBanLists: model.restrictions?.TCG ?? [],
                        mdBanLists: model.restrictions?.MD ?? [],
                        score: model.score,
                        cardDTS: model.cardDTS,
                        cardNE: model.cardNE,
                        retryCB: { await model.fetchCardInfo(forceRefresh: true) },
                        suggestions: {
            SuggestionsParentView(isScrollDisabled: model.suggestionsError != nil
                                  || !model.areSuggestionsLoaded
                                  || !model.hasSuggestions(),
                                  dataCB: { forceRefresh in
                await model.fetchAllSuggestions(forceRefresh: forceRefresh)
            }, suggestionsView: {
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
            }, overlayView: {
                SuggestionOverlayView(areSuggestionsLoaded: model.areSuggestionsLoaded,
                                      noSuggestionsFound: !model.hasSuggestions(),
                                      networkError: model.suggestionsError,
                                      action: {
                    Task {
                        await model.fetchAllSuggestions(forceRefresh: true)
                    }
                })
                .equatable()
            })
        })
        .equatable()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(model.card?.cardName ?? "Loading…")
        .frame(maxWidth:.infinity, maxHeight: .infinity)
        .task {
            await model.fetchCardInfo()
        }
        .onChange(of: model.card) {
            Task {
                let newItem = History(resource: .card, id: model.cardID, timesAccessed: 1)
                newItem.updateHistoryContext(history: cardFromTable, modelContext: modelContext)
            }
        }
    }
    
    private struct CardDetailsView<Suggestions: View>: View, Equatable {
        static func == (lhs: CardInfoView.CardDetailsView<Suggestions>, rhs: CardInfoView.CardDetailsView<Suggestions>) -> Bool {
            lhs.cardDTS == rhs.cardDTS && lhs.cardNE == rhs.cardNE && lhs.score == rhs.score
        }
        
        let cardID: String
        let card: YGOCard?
        let products: [Product]?
        let tcgBanLists: [BanList]
        let mdBanLists: [BanList]
        let score: CardScore?
        let cardDTS: DataTaskStatus
        let cardNE: NetworkError?
        let retryCB: () async -> Void
        @ViewBuilder let suggestions: () -> Suggestions
        
        var body: some View {
            GeometryReader { reader in
                let width = reader.size.width
                TabView {
                    Tab("Info", systemImage: "info.circle.fill") {
                        if cardNE == nil {
                            ScrollView {
                                YGOCardView(cardID: cardID, card: card, width: width)
                                    .equatable()
                                    .padding(.bottom)
                                
                                if let card = card, let products = products {
                                    CardReleasesView(card: card, products: products)
                                        .modifier(.parentView)
                                    
                                    CardRestrictionsView(card: card, tcgBanList: tcgBanLists, mdBanLists: mdBanLists, score: score)
                                        .modifier(.parentView)
                                        .padding(.bottom, 50)
                                } else {
                                    ProgressView("Loading...")
                                        .controlSize(.large)
                                }
                            }
                            .disabled(cardDTS != .done)
                        }
                    }
                    
                    Tab("Suggestions", systemImage: "sparkles") {
                        if cardDTS == .done {
                            suggestions()
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .overlay {
                    if let networkError = cardNE {
                        switch networkError {
                        case .badRequest, .unprocessableEntity:
                            ContentUnavailableView("Card not currently supported",
                                                   systemImage: "exclamationmark.square.fill",
                                                   description: Text("Please check back later"))
                        default:
                            NetworkErrorView(error: networkError, action: {
                                Task {
                                    await retryCB()
                                }
                            })
                        }
                    }
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
