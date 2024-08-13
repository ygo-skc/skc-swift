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
    
    @State private var hasSelfReference: Bool = false
    @State private var namedMaterials: [CardReference]?
    @State private var namedReferences: [CardReference]?
    
    @State private var referencedBy: [CardReference]?
    @State private var materialFor: [CardReference]?
    
    private func loadSuggestions() async {
        if namedMaterials != nil && namedReferences != nil {
            return
        }
        
        request(url: cardSuggestionsURL(cardID: cardID), priority: 0.4) { (result: Result<CardSuggestions, Error>) -> Void in
            switch result {
            case .success(let suggestions):
                DispatchQueue.main.async {
                    self.hasSelfReference = suggestions.hasSelfReference ?? false
                    self.namedMaterials = suggestions.namedMaterials
                    self.namedReferences = suggestions.namedReferences
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func loadSupport() async {
        if referencedBy != nil && materialFor != nil {
            return
        }
        
        request(url: cardSupportURL(cardID: cardID), priority: 0.4) { (result: Result<CardSupport, Error>) -> Void in
            switch result {
            case .success(let support):
                DispatchQueue.main.async {
                    self.referencedBy = support.referencedBy
                    self.materialFor = support.materialFor
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label {
                Text("Suggestions")
                    .font(.title)
            } icon: {
                CardImageView(length: 50, cardID: cardID, imgSize: .tiny)
            }
            .padding(.bottom)
            .frame(maxWidth: .infinity, alignment: .center)
            
            if let namedMaterials, let namedReferences, let referencedBy, let materialFor {
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
            await loadSuggestions()
            await loadSupport()
        }
    }
}

private struct SuggestionHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct SuggestionCarouselView: View {
    let header: String
    let subHeader: String
    let references: [CardReference]
    
    @State private var height: CGFloat = 0.0
    
    var body: some View {
        if (!references.isEmpty) {
            Text(header)
                .font(.title3)
            Text(subHeader)
            
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

struct SupportCarouselView: View {
    let header: String
    let subHeader: String
    let references: [CardReference]
    
    @State private var height: CGFloat = 0.0
    
    var body: some View {
        if (!references.isEmpty) {
            Text(header)
                .font(.title3)
            Text(subHeader)
            
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
