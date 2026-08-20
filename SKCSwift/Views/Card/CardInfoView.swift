//
//  CardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI
import FoundationModels
import os

struct CardInfoView: View {
    @State private var model: CardViewModel
    @State private var containerWidth: CGFloat = 0
    
    init(cardID: String) {
        self.model = .init(cardID: cardID)
    }
    
    @ViewBuilder
    private var suggestions: some View {
        if model.cardDTS == .done, let cardName = model.card?.cardName {
            LazyVStack(alignment: .leading, spacing: 25) {
                Label("Suggestions", systemImage: "sparkles")
                    .font(.title)
                    .task {
                        await model.fetchAllSuggestions()
                    }
                    .task {
                        await model.fetchSimilarCards()
                    }
                
                if model.areSuggestionsLoaded && model.suggestionsError == nil {
                    YGOArchetypesView(title: "Suggested archetypes",
                                      archetypes: model.archetypeSuggestions,
                                      showBetaBadge: true)
                    
                    SuggestionSectionView(header: "Named Materials",
                                          subHeader: "Cards that can be used as summoning material for **\(cardName)**.",
                                          references: model.namedMaterials,
                                          variant: .suggestion)
                    SuggestionSectionView(header: "Named References",
                                          subHeader: "Cards found in the text of **\(cardName)** but aren't explicitly listed as a summoning material.",
                                          references: model.namedReferences,
                                          variant: .suggestion)
                    SuggestionSectionView(header: "Material For",
                                          subHeader: "ED cards that can be summoned using **\(cardName)** as material",
                                          references: model.materialFor,
                                          variant: .support)
                    SuggestionSectionView(header: "Referenced By",
                                          subHeader: "Cards that reference **\(cardName)** excluding ED cards that reference **\(cardName)** as a summoning material.",
                                          references: model.referencedBy,
                                          variant: .support)
                    
                    if model.similarCardsDTS == .done && model.similarCardsNE == nil {
                        SuggestionSectionView(header: "Similar Cards",
                                              subHeader: "Cards that are semantically similar to **\(cardName)**. This could be cards with similar stats/effects/lore/etc.",
                                              references: model.similarCards,
                                              variant: .support)
                    }
                }
                
                SuggestionTransitionView(areSuggestionsLoaded: model.areSuggestionsLoaded,
                                         noSuggestionsFound: !model.hasSuggestions(),
                                         networkError: model.suggestionsError,
                                         action: {
                    Task {
                        if model.similarCardsNE != nil {
                            await model.fetchSimilarCards(forceRefresh: true)
                        }
                        await model.fetchAllSuggestions(forceRefresh: true)
                    }
                })
                .equatable()
            }
            .parentModifier()
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 35) {
                if model.cardDTS != .error {
                    YGOCardView(cardID: model.cardID, card: model.card, width: containerWidth)
                        .equatable()
                    
                    if let cardMechanic = model.cardMechanic {
                        CardMechanicView(cardMechanic: cardMechanic)
                    }
                    
                    if let card = model.card, let products = model.products {
                        CardReleasesView(card: card, products: products)
                            .parentModifier()
                        CardRestrictionsView(card: card,
                                             tcgBanList: model.restrictions?.TCG ?? [],
                                             mdBanLists: model.restrictions?.MD ?? [],
                                             score: model.score)
                        .parentModifier()
                    }
                }
                
                suggestions
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle((model.cardDTS == .pending) ? "Loading…" : model.card?.cardName ?? "")
        .scrollDisabled(model.cardDTS == .error)
        .task {
            await model.fetchCardInfo()
        }
        .onChange(of: model.card) {
            Task {
                await ArchiveContainer.historyActor.recordAccess(resource: .card, id: model.cardID)
            }
        }
        .frame(maxWidth: .infinity) // needed by overlay
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newWidth in
            containerWidth = newWidth
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

private struct CardMechanicView : View {
    let cardMechanic: CardMechanic
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Group {
                    Text("Effect Breakdown")
                    Text("BETA")
                        .tagModifier()
                }
                .headerTextModifier()
            }
            
            if cardMechanic.flavor || (cardMechanic.summonConditions.isEmpty && cardMechanic.effects.isEmpty) {
                ContentUnavailableView("Card has no effects", systemImage: "tray.fill")
            } else {
                ForEach(cardMechanic.summonConditions, id: \.self) { conditions in
                    CardEffectView(effect: conditions.text) {
                        CardMechanicTagView(type: "Tags", tags: conditions.tags)
                    }
                }
                
                ForEach(cardMechanic.effects, id: \.self) { effect in
                    CardEffectView(effect: effect.text) {
                        CardMechanicTagView(type: "Tags", tags: effect.tags)
                        CardMechanicTagView(type: "Counters", tags: effect.counters)
                    }
                }
            }
        }
        .parentModifier()
    }
    
    private struct CardEffectView<Tags: View>: View {
        let effect: String
        let tags: () -> Tags
        
        init(effect: String, @ViewBuilder tags: @escaping () -> Tags) {
            self.effect = effect
            self.tags = tags
        }
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(effect)
                    .font(.callout)
                    .italic()
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 2)
                
                tags()
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(18)
            .background(Color(.secondarySystemGroupedBackground),
                        in: .rect(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(.accent.opacity(0.3), lineWidth: 2)
            }
        }
    }
    
    private struct CardMechanicTagView: View {
        let type: String
        let tags: [String]
        
        var body: some View {
            if tags.count > 0 {
                FlowLayout(spacing: 6) {
                    Text(type)
                        .font(.callout)
                        .fontWeight(.semibold)
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .tagModifier(.neutral, font: .caption)
                    }
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
