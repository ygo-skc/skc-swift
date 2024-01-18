//
//  CardSuggestionsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/29/23.
//

import SwiftUI

struct CardSuggestionsView: View {
    var cardID: String
    
    @State var hasSelfReference: Bool = false
    @State var namedMaterials: [CardReference] = [CardReference]()
    @State var namedReferences: [CardReference] = [CardReference]()
    @State var isSuggestionDataLoaded = false
    
    @State var referencedBy: [Card] = [Card]()
    @State var materialFor: [Card] = [Card]()
    @State var isSupportDataLoaded = false
    
    private func loadSuggestions() {
        if isSuggestionDataLoaded {
            return
        }
        
        request(url: cardSuggestionsURL(cardID: cardID)) { (result: Result<CardSuggestions, Error>) -> Void in
            DispatchQueue.main.async {
                switch result {
                case .success(let suggestions):
                    self.hasSelfReference = suggestions.hasSelfReference
                    self.namedMaterials = suggestions.namedMaterials
                    self.namedReferences = suggestions.namedReferences
                    
                    self.isSuggestionDataLoaded = true
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private func loadSupport() {
        if isSupportDataLoaded {
            return
        }
        
        request(url: cardSupportURL(cardID: cardID)) { (result: Result<CardSupport, Error>) -> Void in
            DispatchQueue.main.async {
                switch result {
                case .success(let support):
                    self.referencedBy = support.referencedBy
                    self.materialFor = support.materialFor
                    
                    self.isSupportDataLoaded = true
                case .failure(let error):
                    print(error)
                }
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
            .onAppear {
                loadSuggestions()
                loadSupport()
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
    var references: [Card]
    
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
                    ForEach(references, id: \.cardID) { card in
                        NavigationLink(value: CardValue(cardID: card.cardID, cardName: card.cardName), label: {
                            YGOCardView(card: card, isDataLoaded: true, variant: .condensed)
                                .contentShape(Rectangle())
                        })
                        .buttonStyle(PlainButtonStyle())
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
