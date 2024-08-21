//
//  CardSuggestionsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/29/23.
//

import SwiftUI

struct CardSuggestionsView: View {
    let cardID: String
    let cardName: String
    private let suggestionViewModel = CardSuggestionViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label {
                Text("Suggestions")
                    .font(.title2)
            } icon: {
                CardImageView(length: 50, cardID: cardID, imgSize: .tiny)
            }
            .padding(.bottom)
            .frame(maxWidth: .infinity, alignment: .center)
            
            if suggestionViewModel.areSuggestionsLoaded && suggestionViewModel.isSupportLoaded,
               let namedMaterials = suggestionViewModel.namedMaterials, let namedReferences = suggestionViewModel.namedReferences,
               let referencedBy = suggestionViewModel.referencedBy, let materialFor = suggestionViewModel.materialFor {
                if namedMaterials.isEmpty && namedReferences.isEmpty && referencedBy.isEmpty && materialFor.isEmpty {
                    ContentUnavailableView("No suggestions found 🤯", systemImage: "exclamationmark.square.fill")
                } else {
                    SuggestionCarouselView(header: "Named Materials",
                                           subHeader: "Cards that can be used as summoning material for \(cardName).", references: namedMaterials)
                    SuggestionCarouselView(header: "Named References",
                                           subHeader: "All other cards found in the text of \(cardName) - non materials.", references: namedReferences)
                    SupportCarouselView(header: "Material For",
                                        subHeader: "ED cards that can be summoned using \(cardName) as material", references: materialFor)
                    SupportCarouselView(header: "Referenced By",
                                        subHeader: "Cards that reference \(cardName) - excludes ED cards that reference this card as a summoning material.", references: referencedBy)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task(priority: .userInitiated) {
            await suggestionViewModel.fetchSuggestions(cardID: cardID)
        }
        .task(priority: .userInitiated) {
            await suggestionViewModel.fetchSupport(cardID: cardID)
        }
    }
}

struct ProductCardSuggestionsView: View {
    let productID: String
    let productName: String
    
    @State private var suggestions: ProductSuggestions? = nil
    
    private func fetch() async {
        if suggestions == nil, let suggestions = try? await data(ProductSuggestions.self, url: productSuggestionsURL(productID: productID)) {
            DispatchQueue.main.async {
                self.suggestions = suggestions
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label {
                Text("Suggestions")
                    .font(.title2)
            } icon: {
                ProductImage(width: 50, productID: productID, imgSize: .tiny)
            }
            .padding(.bottom)
            .frame(maxWidth: .infinity, alignment: .center)
            
            if let suggestions {
                SuggestionCarouselView(header: "Named Materials", 
                                       subHeader: "Cards that can be used as summoning material for a card included in \(productName).",
                                       references: suggestions.suggestions.namedMaterials)
                SuggestionCarouselView(header: "Named References", 
                                       subHeader: "All other cards found in the text of a card included in \(productName) which cannot be used a summoning material.",
                                       references: suggestions.suggestions.namedReferences)
                SupportCarouselView(header: "Material For", 
                                    subHeader: "ED cards that can be summoned using a card found in \(productName).",
                                    references: suggestions.support.materialFor)
                SupportCarouselView(header: "Referenced By", 
                                    subHeader: "Cards that reference a card found in \(productName). Excludes ED cards that reference this card as a summoning material.",
                                    references: suggestions.support.referencedBy)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        }
        .task(priority: .userInitiated) {
            await fetch()
        }
    }
}

private struct SuggestionHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct SuggestionCarouselView: View {
    let header: String
    let subHeader: String
    let references: [CardReference]
    
    @State private var height: CGFloat = 0.0
    
    var body: some View {
        if (!references.isEmpty) {
            Text(header)
                .font(.title3)
            Text(subHeader)
                .padding(.bottom)
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(references, id: \.card.cardID) { suggestion in
                        SuggestedCardView(card: suggestion.card, occurrence: suggestion.occurrences)
                            .background(GeometryReader { geometry in
                                Color.clear.preference(
                                    key: SuggestionHeightPreferenceKey.self,
                                    value: geometry.size.height
                                )
                            })
                            .onPreferenceChange(SuggestionHeightPreferenceKey.self) {
                                height = $0
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: height)
            .padding(.horizontal, -16)
            .padding(.bottom, 15)
        }
    }
}

private struct SupportCarouselView: View {
    let header: String
    let subHeader: String
    let references: [CardReference]
    
    @State private var height: CGFloat = 0.0
    
    var body: some View {
        if (!references.isEmpty) {
            Text(header)
                .font(.title3)
            Text(subHeader)
                .padding(.bottom)
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(references, id: \.card.cardID) { reference in
                        let card = reference.card
                        NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
                            YGOCardView(cardID: card.cardID, card: card, variant: .condensed)
                                .equatable()
                                .contentShape(Rectangle())
                        })
                        .buttonStyle(.plain)
                        .background(GeometryReader { geometry in
                            Color.clear.preference(
                                key: SuggestionHeightPreferenceKey.self,
                                value: geometry.size.height
                            )
                        })
                        .onPreferenceChange(SuggestionHeightPreferenceKey.self) {
                            height = $0
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: height)
            .padding(.horizontal, -16)
            .padding(.bottom, 15)
        }
    }
}

#Preview("Air Neos Suggestions") {
    ScrollView {
        CardSuggestionsView(cardID: "11502550", cardName: "Elemental HERO Air Neos")
            .padding(.horizontal)
    }
}

#Preview("Dark Magician Girl Suggestions") {
    ScrollView {
        CardSuggestionsView(cardID: "38033121", cardName: "Dark Magician Girl")
            .padding(.horizontal)
    }
}
