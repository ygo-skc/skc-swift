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
    @Binding private var path: NavigationPath
    @State private var model: CardViewModel
    @State private var containerWidth: CGFloat = 0
    
    init(path: Binding<NavigationPath>, cardID: String) {
        self._path = path
        self.model = .init(cardID: cardID)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 35) {
                if model.cardDTS != .error {
                    YGOCardView(cardID: model.cardID, card: model.card, width: containerWidth)
                        .equatable()
                    
                    if #available(iOS 26.0, *),
                       model.cardDTS == .done,
                       let cardColor = model.card?.cardColor, cardColor != "Normal",
                       let cardEffect = model.card?.cardEffect, !cardEffect.isEmpty {
                        CardAISummary(cardEffect: cardEffect)
                    }
                    
                    if let card = model.card, let products = model.products {
                        CardReleasesView(path: $path, card: card, products: products)
                            .parentModifier()
                        CardRestrictionsView(card: card,
                                             tcgBanList: model.restrictions?.TCG ?? [],
                                             mdBanLists: model.restrictions?.MD ?? [],
                                             score: model.score)
                        .parentModifier()
                    }
                }
                
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

@available(iOS 26.0, *)
private struct CardAISummary: View {
    let cardEffect: String
    @State private var result: CardClauses = CardClauses(Clauses: [])
    @State private var isLoading = true
    
    private var prompt: String {
        return """
            This is the card text you will parse: 
            \(cardEffect)
            """
    }
    
    var body: some View {
        if case .available = SystemLanguageModel.default.availability {
            VStack(alignment: .leading, spacing: 10) {
                Label("AI Breakdown", systemImage: "sparkles")
                    .font(.headline)
                
                if isLoading {
                    AISummaryPlaceholder()
                } else {
                    Text(result.Clauses.enumerated()
                        .map { "(\($0.offset + 1)) \($0.element)" }
                        .joined(separator: "\n"))
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .parentModifier()
            .task(id: cardEffect) {
                let session = LanguageModelSession(instructions: CardInfoPrompt.CARD_EFFECT_CLAUSES.description)
                do {
                    result = try await session.respond(
                        to: prompt,
                        generating: CardClauses.self,
                        includeSchemaInPrompt: true,
                        options: GenerationOptions(sampling: .greedy)
                    ).content
                } catch let e {
                    Logger.ui.error("Error occurred while creating card effect clauses: \(e, privacy: .public)")
                }
                isLoading = false
            }
        }
    }
}

private struct AISummaryPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .frame(maxWidth: .infinity, minHeight: 12)
            RoundedRectangle(cornerRadius: 4)
                .frame(maxWidth: 220, minHeight: 12)
            RoundedRectangle(cornerRadius: 4)
                .frame(maxWidth: 100, minHeight: 12)
        }
        .foregroundStyle(.purple.opacity(0.3))
        .phaseAnimator([0.4, 1.0]) { view, opacity in
            view.opacity(opacity)
        } animation: { _ in
                .easeInOut(duration: 0.45).repeatForever(autoreverses: true)
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
