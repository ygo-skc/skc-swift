//
//  CardSuggestionsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/29/23.
//

import SwiftUI

struct SuggestionOverlayView: View, Equatable {
    static func == (lhs: SuggestionOverlayView, rhs: SuggestionOverlayView) -> Bool {
        lhs.areSuggestionsLoaded == rhs.areSuggestionsLoaded
        && lhs.noSuggestionsFound == rhs.noSuggestionsFound
    }
    
    let areSuggestionsLoaded: Bool
    let noSuggestionsFound: Bool
    
    let networkError: NetworkError?
    let action: () -> Void
    
    var body: some View {
        if let networkError {
            NetworkErrorView(error: networkError, action: action)
        } else if areSuggestionsLoaded, noSuggestionsFound {
            ContentUnavailableView("No suggestions found 🤯", systemImage: "exclamationmark.square.fill")
        } else if !areSuggestionsLoaded {
            HStack {
                ProgressView("Loading...")
                    .controlSize(.large)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

enum CarouselItemVariant {
    case suggestion
    case support
}

struct SuggestionSectionView: View {
    let header: String
    let subHeader: String
    let references: [CardReference]
    let variant: CarouselItemVariant
    
    var body: some View {
        if !references.isEmpty {
            VStack(alignment: .leading) {
                Text("\(header) (\(references.count))")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(LocalizedStringKey(subHeader))
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                SuggestionCarouselView(references: references, variant: variant)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct SuggestionCarouselView: View {
    let references: [CardReference]
    let variant: CarouselItemVariant
    
    @State private var height: CGFloat = 0
    
    init(references: [CardReference], variant: CarouselItemVariant) {
        self.references = references
        self.variant = variant
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 8) {
                ForEach(references, id: \.card.cardID) { suggestion in
                    switch variant {
                    case .suggestion:
                        SuggestedCardView(card: suggestion.card, occurrence: suggestion.occurrences)
                            .modifier(CarouselItemViewModifier(height: $height))
                    case .support:
                        let card = suggestion.card
                        NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
                            YGOCardView(cardID: card.cardID, card: card, variant: .condensed)
                                .equatable()
                        })
                        .modifier(CarouselItemViewModifier(height: $height))
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: height)
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByFew))
        .scrollIndicators(.automatic)
    }
}

private struct CarouselItemViewModifier: ViewModifier {
    @Binding var height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .overlay(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            height = max(height, geometry.size.height)
                        }
                        .onChange(of: geometry.size.height) {
                            height = max(height, geometry.size.height)
                        }
                }
            )
    }
}

private struct SuggestedCardView: View {
    var card: YGOCard
    var occurrence: Int
    
    var body: some View {
        NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
            VStack(spacing: 5) {
                HStack(spacing: 15) {
                    CardImageView(length: 75, cardID: card.cardID, imgSize: .tiny, variant: .roundedCorner)
                        .equatable()
                    
                    Text("\(occurrence) Reference(s)")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                CardStatsView(card: card, variant: .condensed)
                    .equatable()
            }
            .frame(width: 220)
        })
    }
}

#Preview("Air Neos Suggestions") {
    @Previewable @State var model = CardViewModel(cardID: "11502550")
    
    ScrollView {
        VStack {
            if model.supportDTS == .done && model.suggestionsDTS == .done, let cardName = model.card?.cardName {
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
                                      subHeader: "Cards that reference **\(cardName)** excluding ED cards that reference **\(cardName)** as a summoning material.",
                                      references: model.referencedBy ?? [],
                                      variant: .support)
            }
        }
        .modifier(.parentView)
        .task {
            await model.fetchCardInfo()
            await model.fetchAllSuggestions()
        }
    }
}

#Preview("Dark Magician Girl Suggestions") {
    @Previewable @State var model = CardViewModel(cardID: "38033121")
    
    ScrollView {
        VStack {
            if model.supportDTS == .done && model.suggestionsDTS == .done, let cardName = model.card?.cardName {
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
                                      subHeader: "Cards that reference **\(cardName)** excluding ED cards that reference **\(cardName)** as a summoning material.",
                                      references: model.referencedBy ?? [],
                                      variant: .support)
            }
        }
        .modifier(.parentView)
        .task {
            await model.fetchCardInfo()
            await model.fetchAllSuggestions()
        }
    }
}

#Preview {
    SuggestedCardView(
        card: YGOCard(
            cardID: "40044918",
            cardName: "Elemental HERO Stratos",
            cardColor: "Effect",
            cardAttribute: "Wind",
            cardEffect: "Draw 2",
            monsterType: "Warrior/Effect"
        ), occurrence: 1)
}
