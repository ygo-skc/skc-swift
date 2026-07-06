//
//  CardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI
import SwiftData
import FoundationModels

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
            VStack(spacing: 25) {
                if model.cardDTS != .error {
                    YGOCardView(cardID: model.cardID, card: model.card, width: UIScreen.main.bounds.width)
                        .equatable()
                    
                    if #available(iOS 26.0, *),
                       model.cardDTS == .done,
                       let cardColor = model.card?.cardColor, cardColor != "Normal",
                       let cardEffect = model.card?.cardEffect, !cardEffect.isEmpty {
                        CardAISummary(cardEffect: cardEffect)
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
                
                if model.cardDTS == .done, let cardName = model.card?.cardName {
                    LazyVStack(alignment: .leading, spacing: 25) {
                        Label("Suggestions", systemImage: "sparkles")
                            .font(.title)
                            .task {
                                await model.fetchAllSuggestions()
                            }
                        
                        if model.areSuggestionsLoaded && model.suggestionsError == nil {
                            YGOArchetypesView(title: "Suggested archetypes (BETA)",
                                              archetypes: model.archetypeSuggestions)
                            
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
                let newItem = History(resource: .card, id: model.cardID, lastAccessDate: Date(), timesAccessed: 1)
                newItem.updateHistoryContext(history: cardFromTable, modelContext: modelContext)
            }
        }
        .frame(maxWidth: .infinity) // needed by overlay
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
    @State private var result: CardEffects = CardEffects(effects: [])
    @State private var isLoading = true
    
    private var prompt: String {
        return """
            Parse the following card text:
            <text>\(cardEffect)</text>
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
                    Text(result.effects.enumerated()
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
                        generating: CardEffects.self,
                        includeSchemaInPrompt: true,
                        options: GenerationOptions(sampling: .greedy)
                    ).content
                } catch let e {
                    print("Error occurred while creating card effect clauses \(e)")
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
