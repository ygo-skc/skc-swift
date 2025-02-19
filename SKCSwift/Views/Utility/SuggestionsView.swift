//
//  CardSuggestionsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/29/23.
//

import SwiftUI

struct CardSuggestionsView: View {
    let model: CardViewModel
    
    var body: some View {
        ScrollView {
            SuggestionsView(
                subjectID: model.cardID,
                subjectName: model.card?.cardName ?? "",
                subjectType: .card,
                areSuggestionsLoaded: model.areSuggestionsLoaded && model.isSupportLoaded,
                hasSuggestions: model.hasSuggestions(),
                namedMaterials: model.namedMaterials ?? [],
                namedReferences: model.namedReferences ?? [],
                referencedBy: model.referencedBy ?? [],
                materialFor: model.materialFor ?? []
            )
            .modifier(ParentViewModifier(alignment: .center))
            .padding(.bottom, 30)
        }
        .task(priority: .userInitiated) {
            await model.fetchSuggestions()
        }
        .task(priority: .userInitiated) {
            await model.fetchSupport()
        }
        .overlay {
            SuggestionOverlayView(areSuggestionsLoaded: model.areSuggestionsLoaded && model.isSupportLoaded,
                                  noSuggestionsFound: !model.hasSuggestions(),
                                  networkError: model.requestErrors[.suggestions, default: nil] ?? model.requestErrors[.support, default: nil],
                                  action: {
                Task {
                    model.resetSuggestionErrors()
                    await model.fetchSuggestions(forceRefresh: true)
                    await model.fetchSupport(forceRefresh: true)
                }
            })
        }
    }
}

struct SuggestionOverlayView: View {
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
            ProgressView("Loading...")
                .controlSize(.large)
        }
    }
}

struct ProductCardSuggestionsView: View {
    let model: ProductViewModel
    
    var body: some View {
        ScrollView {
            SuggestionsView(
                subjectID: model.productID,
                subjectName: model.product?.productName,
                subjectType: .product,
                areSuggestionsLoaded: model.suggestions != nil,
                hasSuggestions: model.hasSuggestions(),
                namedMaterials: model.suggestions?.suggestions.namedMaterials ?? [],
                namedReferences: model.suggestions?.suggestions.namedReferences ?? [],
                referencedBy: model.suggestions?.support.referencedBy ?? [],
                materialFor: model.suggestions?.support.materialFor ?? []
            )
            .modifier(ParentViewModifier(alignment: .center))
            .padding(.bottom, 30)
        }
        .scrollDisabled(model.requestErrors[.suggestions, default: nil] != nil)
        .task(priority: .userInitiated) {
            await model.fetchProductSuggestions()
        }
        .overlay {
            SuggestionOverlayView(areSuggestionsLoaded: model.suggestions != nil,
                                  noSuggestionsFound: !model.hasSuggestions(),
                                  networkError: model.requestErrors[.suggestions, default: nil],
                                  action: {
                Task {
                    model.resetSuggestionErrors()
                    await model.fetchProductSuggestions(forceRefresh: true)
                }
            })
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
    let hasSuggestions: Bool
    let namedMaterials: [CardReference]
    let namedReferences: [CardReference]
    let referencedBy: [CardReference]
    let materialFor: [CardReference]
    
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
            return "Cards found in the text of **\(subjectName ?? "")** but aren't explicitly listed as a summoning material."
        case .product:
            return "Cards found in the text of a card included in **\(subjectName ?? "")** but aren't explicitly listed as a summoning material."
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
            return "Cards that reference **\(subjectName ?? "")** excluding ED cards that reference **\(subjectName ?? "")** as a summoning material."
        case .product:
            return "Cards that reference a card found in **\(subjectName ?? "")** excluding ED cards that reference a card in this set as a summoning material."
        }
    }
    
    var body: some View {
        VStack {
            Label {
                Text("Suggestions")
                    .font(.title)
            } icon: {
                switch subjectType {
                case .card:
                    CardImageView(length: 50, cardID: subjectID, imgSize: .tiny)
                case .product:
                    ProductImageView(width: 50, productID: subjectID, imgSize: .tiny)
                }
            }
            .padding(.bottom)
            
            if areSuggestionsLoaded && hasSuggestions {
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
            Text("\(header) (\(references.count))")
                .font(.headline)
                .fontWeight(.heavy)
            Text(LocalizedStringKey(subHeader))
                .font(.callout)
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
            .onPreferenceChange(SuggestionHeightPreferenceKey.self) { h in
                Task { @MainActor in
                    height = h
                }
            }
    }
}

#Preview("Air Neos Suggestions") {
    let model = CardViewModel(cardID: "11502550")
    
    ScrollView {
        CardSuggestionsView(model: model)
            .padding(.horizontal)
    }
    .task {
        await model.fetchCardData()
    }
}

#Preview("Dark Magician Girl Suggestions") {
    let model = CardViewModel(cardID: "38033121")
    
    ScrollView {
        CardSuggestionsView(model: model)
            .padding(.horizontal)
    }
    .task {
        await model.fetchCardData()
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
