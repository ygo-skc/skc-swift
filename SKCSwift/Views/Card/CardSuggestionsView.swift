//
//  CardSuggestionsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/29/23.
//

import SwiftUI

struct CardSuggestionsView: View {
    var cardID: String
    
    @State private var hasSelfReference: Bool = false
    @State private var namedMaterials: [CardReference] = [CardReference]()
    @State private var namedReferences: [CardReference] = [CardReference]()
    @State private var isSuggestionDataLoaded = false
    
    @State private var referencedBy: [CardReference] = [CardReference]()
    @State private var materialFor: [CardReference] = [CardReference]()
    @State private var isSupportDataLoaded = false
    
    private func loadSuggestions() async {
        if isSuggestionDataLoaded {
            return
        }
        
        request(url: cardSuggestionsURL(cardID: cardID), priority: 0.2) { (result: Result<CardSuggestions, Error>) -> Void in
            switch result {
            case .success(let suggestions):
                DispatchQueue.main.async {
                    self.hasSelfReference = suggestions.hasSelfReference
                    self.namedMaterials = suggestions.namedMaterials
                    self.namedReferences = suggestions.namedReferences
                    
                    self.isSuggestionDataLoaded = true
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func loadSupport() async {
        if isSupportDataLoaded {
            return
        }
        
        request(url: cardSupportURL(cardID: cardID), priority: 0.2) { (result: Result<CardSupport, Error>) -> Void in
            switch result {
            case .success(let support):
                DispatchQueue.main.async {
                    self.referencedBy = support.referencedBy
                    self.materialFor = support.materialFor
                    
                    self.isSupportDataLoaded = true
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    var body: some View {
        SectionView(header: "Suggestions",
                    variant: .plain,
                    content: {
            VStack(alignment: .leading, spacing: 5) {
                if isSuggestionDataLoaded && isSupportDataLoaded {
                    Text("Other cards that have a tie of sorts with currently selected card. These could be summoning materials for example.")
                        .padding(.bottom)
                    if namedMaterials.isEmpty && namedReferences.isEmpty && referencedBy.isEmpty && materialFor.isEmpty {
                        Text("Nothing to suggest 🤔")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom)
                    } else {
                        SuggestionCarouselView(header: "Named Materials", subHeader: "Cards that can be used as summoning material", references: namedMaterials)
                        SuggestionCarouselView(header: "Named References", subHeader: "Cards found in card text - non materials", references: namedReferences)
                        SupportCarouselView(header: "Material For", subHeader: "Cards that can be summoned using this card as material", references: materialFor)
                        SupportCarouselView(header: "Referenced By", subHeader: "Cards that reference this card - excludes ED cards that reference this card as a summoning material", references: referencedBy)
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            .task(priority: .userInitiated) {
                await loadSuggestions()
                await loadSupport()
            }
        })
    }
}

private struct SuggestionnHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct SuggestionCarouselView: View {
    var header: String
    var subHeader: String
    var references: [CardReference]
    
    @State private var height: CGFloat = 0.0
    
    var body: some View {
        if (!references.isEmpty) {
            Text(header)
                .font(.headline)
                .fontWeight(.heavy)
            
            Text(subHeader)
                .padding(.bottom)
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 15) {
                    ForEach(references, id: \.card.cardID) { suggestion in
                        SuggestedCardView(card: suggestion.card, occurrence: suggestion.occurrences)
                            .background(GeometryReader { geometry in
                                Color.clear.preference(
                                    key: SuggestionnHeightPreferenceKey.self,
                                    value: geometry.size.height
                                )
                            })
                            .onPreferenceChange(SuggestionnHeightPreferenceKey.self) {
                                height = $0
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: height)
            .padding(.horizontal, -16)
            .padding(.bottom, 20)
        }
    }
}

private struct SupportCarouselView: View {
    var header: String
    var subHeader: String
    var references: [CardReference]
    
    @State private var height: CGFloat = 0.0
    
    var body: some View {
        if (!references.isEmpty) {
            Text(header)
                .font(.headline)
                .fontWeight(.heavy)
            
            Text(subHeader)
                .padding(.bottom)
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 15) {
                    ForEach(references, id: \.card.cardID) { reference in
                        let card = reference.card
                        NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
                            YGOCardView(card: card, isDataLoaded: true, variant: .condensed)
                                .equatable()
                                .contentShape(Rectangle())
                        })
                        .buttonStyle(.plain)
                        .background(GeometryReader { geometry in
                            Color.clear.preference(
                                key: SuggestionnHeightPreferenceKey.self,
                                value: geometry.size.height
                            )
                        })
                        .onPreferenceChange(SuggestionnHeightPreferenceKey.self) {
                            height = $0
                        }
                        
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: height)
            .padding(.horizontal, -16)
            .padding(.bottom, 20)
        }
    }
}

#Preview("Air Neos Suggestions") {
    ScrollView {
        CardSuggestionsView(cardID: "11502550")
            .padding(.horizontal)
    }
}

#Preview("Dark Magician Girl Suggestions") {
    ScrollView {
        CardSuggestionsView(cardID: "38033121")
            .padding(.horizontal)
    }
}
