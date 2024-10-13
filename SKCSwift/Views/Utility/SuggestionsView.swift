//
//  CardSuggestionsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/29/23.
//

import SwiftUI

struct CardSuggestionsView: View {
    let cardID: String
    let cardName: String?
    
    private let suggestionViewModel = CardSuggestionViewModel()
    
    var body: some View {
        SuggestionsView(
            subjectID: cardID,
            subjectName: cardName,
            subjectType: .card,
            areSuggestionsLoaded: suggestionViewModel.areSuggestionsLoaded && suggestionViewModel.isSupportLoaded,
            namedMaterials: suggestionViewModel.namedMaterials,
            namedReferences: suggestionViewModel.namedReferences,
            referencedBy: suggestionViewModel.referencedBy,
            materialFor: suggestionViewModel.materialFor
        )
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
    let productName: String?
    
    @State private var suggestions: ProductSuggestions? = nil
    
    private func fetch() async {
        if suggestions == nil {
            switch await data(ProductSuggestions.self, url: productSuggestionsURL(productID: productID)) {
            case .success(let suggestions):
                self.suggestions = suggestions
            case .failure(_): break
            }
        }
    }
    
    var body: some View {
        SuggestionsView(
            subjectID: productID,
            subjectName: productName,
            subjectType: .product,
            areSuggestionsLoaded: suggestions != nil,
            namedMaterials: suggestions?.suggestions.namedMaterials,
            namedReferences: suggestions?.suggestions.namedReferences,
            referencedBy: suggestions?.support.referencedBy,
            materialFor: suggestions?.support.materialFor
        )
        .task(priority: .userInitiated) {
            await fetch()
        }
    }
}

private enum CardSuggestionSubject {
    case card
    case product
}

private struct SuggestionsView: View {
    let subjectID: String
    let subjectName: String?
    let subjectType: CardSuggestionSubject
    
    let areSuggestionsLoaded: Bool
    let namedMaterials: [CardReference]?
    let namedReferences: [CardReference]?
    let referencedBy: [CardReference]?
    let materialFor: [CardReference]?
    
    private var namedMaterialSubHeader: String {
        switch subjectType {
        case .card:
            return "Cards that can be used as summoning material for **\(subjectName ?? "")**."
        case .product:
            return "Cards that can be used as summoning material for a card included in **\(subjectName ?? "")**."
        }
    }
    
    private var namedReferenceSubHeader: String {
        switch subjectType {
        case .card:
            return "Cards found in the text of **\(subjectName ?? "")** - non materials."
        case .product:
            return "Cards found in the text of a card included in **\(subjectName ?? "")** which cannot be used a summoning material."
        }
    }
    
    private var materialForSubHeader: String {
        switch subjectType {
        case .card:
            return "ED cards that can be summoned using **\(subjectName ?? "")** as material"
        case .product:
            return "ED cards that can be summoned using a card found in **\(subjectName ?? "")**."
        }
    }
    
    private var referencedBySubHeader: String {
        switch subjectType {
        case .card:
            return "Cards that reference **\(subjectName ?? "")** excluding ED cards that reference this card as a summoning material."
        case .product:
            return "Cards that reference a card found in **\(subjectName ?? "")** excluding ED cards that reference a card in this set as a summoning material."
        }
    }
    
    var body: some View {
        VStack {
            Label {
                Text("Suggestions")
                    .font(.title2)
            } icon: {
                switch subjectType {
                case .card:
                    CardImageView(length: 50, cardID: subjectID, imgSize: .tiny)
                case .product:
                    ProductImageView(width: 50, productID: subjectID, imgSize: .tiny)
                }
            }
            .padding(.bottom)
            
            if areSuggestionsLoaded, let namedMaterials, let namedReferences , let materialFor, let referencedBy {
                if namedMaterials.isEmpty && namedReferences.isEmpty && referencedBy.isEmpty && materialFor.isEmpty {
                    ContentUnavailableView("No suggestions found 🤯", systemImage: "exclamationmark.square.fill")
                } else {
                    VStack(alignment: .leading, spacing: 5) {
                        SuggestionCarouselView(header: "Named Materials",
                                               subHeader: namedMaterialSubHeader,
                                               references: namedMaterials,
                                               variant: .suggestion)
                        SuggestionCarouselView(header: "Named References",
                                               subHeader: namedReferenceSubHeader,
                                               references: namedReferences,
                                               variant: .suggestion)
                        SuggestionCarouselView(header: "Material For",
                                               subHeader: materialForSubHeader,
                                               references: materialFor,
                                               variant: .support)
                        SuggestionCarouselView(header: "Referenced By",
                                               subHeader: referencedBySubHeader,
                                               references: referencedBy,
                                               variant: .support)
                    }
                }
            } else {
                ProgressView("Loading...")
                    .controlSize(.large)
            }
        }
    }
}

private struct SuggestionHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private enum CarouselItemVariant {
    case suggestion
    case support
}

private struct SuggestionCarouselView: View {
    let header: String
    let subHeader: String
    let references: [CardReference]
    let variant: CarouselItemVariant
    
    @State private var height: CGFloat = 0.0
    
    var body: some View {
        if (!references.isEmpty) {
            Text(header)
                .font(.title3)
            Text(LocalizedStringKey(subHeader))
                .padding(.bottom)
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(references, id: \.card.cardID) { suggestion in
                        switch variant {
                        case .suggestion:
                            SuggestedCardView(card: suggestion.card, occurrence: suggestion.occurrences)
                                .modifier(CarouselItemViewModifier())
                        case .support:
                            let card = suggestion.card
                            NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
                                YGOCardView(cardID: card.cardID, card: card, variant: .condensed)
                                    .equatable()
                                    .contentShape(Rectangle())
                            })
                            .modifier(CarouselItemViewModifier())
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

struct CarouselItemViewModifier: ViewModifier {
    @State private var height: CGFloat = 0.0
    
    func body(content: Content) -> some View {
        content
            .buttonStyle(.plain)
            .background(
                GeometryReader { geometry in
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

private struct SuggestedCardView: View {
    var card: Card
    var occurrence: Int
    
    var body: some View {
        NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
            VStack {
                HStack(spacing: 10) {
                    CardImageView(length: 75, cardID: card.cardID, imgSize: .tiny, variant: .roundedCorner)
                        .equatable()
                    
                    Text("\(occurrence) Reference(s)")
                        .font(.subheadline)
                }
                .padding(.horizontal)
                .frame(width: 220)
                
                CardStatsView(card: card, variant: .condensed)
                    .equatable()
            }
            .contentShape(Rectangle())
            .frame(width: 220)
        })
    }
}

#Preview {
    SuggestedCardView(
        card: Card(
            cardID: "40044918",
            cardName: "Elemental HERO Stratos",
            cardColor: "Effect",
            cardAttribute: "Wind",
            cardEffect: "Draw 2",
            monsterType: "Warrior/Effect"
        ), occurrence: 1)
}
