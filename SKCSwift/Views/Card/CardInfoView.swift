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
        GeometryReader { reader in
            let width = reader.size.width
            CardScreenView() {
                if model.cardDTS != .error {
                    CardDetailsView(cardDTS: model.cardDTS) {
                        YGOCardView(cardID: model.cardID, card: model.card, width: width).equatable()
                    } relatedContent: {
                        if let card = model.card, let products = model.products {
                            VStack(spacing: 30) {
                                CardReleasesView(card: card, products: products)
                                CardRestrictionsView(card: card,
                                                     tcgBanList: model.restrictions?.TCG ?? [],
                                                     mdBanLists: model.restrictions?.MD ?? [],
                                                     score: model.score)
                            }
                            .modifier(.parentView)
                            .padding(.bottom, 50)
                        }
                    }
                }
            } suggestions: {
                if model.cardDTS == .done {
                    SuggestionsParentView(isScrollDisabled: model.suggestionsError != nil
                                          || !model.areSuggestionsLoaded
                                          || !model.hasSuggestions(),
                                          suggestionsView: {
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
                    })
                    .task {
                        await model.fetchAllSuggestions()
                    }
                    .overlay {
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
}

private struct CardDetailsView<YGOCard: View, RelatedContent: View>: View {
    let cardDTS: DataTaskStatus
    let ygoCard: YGOCard
    let relatedContent: RelatedContent
    
    init(cardDTS: DataTaskStatus,
         @ViewBuilder ygoCard: () -> YGOCard,
         @ViewBuilder relatedContent: () -> RelatedContent) {
        self.cardDTS = cardDTS
        self.ygoCard = ygoCard()
        self.relatedContent = relatedContent()
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ygoCard
                    .padding(.bottom)
                relatedContent
            }
        }
        .scrollDisabled(cardDTS == .error)
    }
}

private struct CardScreenView<Details: View, Suggestions: View>: View {
    let details: Details
    let suggestions: Suggestions
    
    init(@ViewBuilder details: () -> Details,
         @ViewBuilder suggestions: () -> Suggestions) {
        self.details = details()
        self.suggestions = suggestions()
    }
    
    var body: some View {
        TabView {
            Tab("Info", systemImage: "info.circle.fill") {
                details
            }
            
            Tab("Suggestions", systemImage: "sparkles") {
                suggestions
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
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
