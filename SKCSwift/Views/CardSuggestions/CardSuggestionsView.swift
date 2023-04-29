//
//  CardSuggestionsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/29/23.
//

import SwiftUI

struct CardSuggestionsView: View {
    var cardId: String
    
    @State private(set) var hasSelfReference: Bool = false
    @State private(set) var namedMaterials: [CardReference] = [CardReference]()
    @State private(set) var namedReferences: [CardReference] = [CardReference]()
    @State private(set) var isDataLoaded = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if (!isDataLoaded) {
                RectPlaceholderView(width: .infinity, height: 150, radius: 10)
            } else {
                Text("Card Suggestions")
                    .font(.title)
                    .padding(.top)
                
                Text("Other cards that have a tie of sorts with currently selected card. These could be summoning materials for example.")
                    .fontWeight(.light)
                    .padding(.top, -10)
                
                if (namedMaterials.isEmpty && namedReferences.isEmpty) {
                    Text("Nothing here 🤔")
                        .font(.subheadline)
                        .padding(.all)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    NamedSuggestionsView(header: "Named Materials", references: namedMaterials)
                    NamedSuggestionsView(header: "Named References", references: namedReferences)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.all)
        .onAppear {
            if isDataLoaded {
                return
            }
            
            request(url: cardSuggestionsURL(cardId: cardId)) { (result: Result<CardSuggestions, Error>) -> Void in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let suggestions):
                        self.hasSelfReference = suggestions.hasSelfReference
                        self.namedMaterials = suggestions.namedMaterials
                        self.namedReferences = suggestions.namedReferences
                        
                        self.isDataLoaded = true
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}

private struct NamedSuggestionsView: View {
    var header: String
    var references: [CardReference]
    
    var body: some View {
        if (!references.isEmpty) {
            Text(header)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(references, id: \.card.cardID) { suggestion in
                        SuggestedCardView(cardId: suggestion.card.cardID, cardName: suggestion.card.cardName, cardColor: suggestion.card.cardColor,
                                          cardEffect: suggestion.card.cardEffect, cardAttribute: suggestion.card.cardAttribute, monsterType: suggestion.card.monsterType,
                                          monsterAttack: suggestion.card.monsterAttack, monsterDefense: suggestion.card.monsterDefense, occurrence: suggestion.occurrences
                        )
                    }
                }
            }
            .padding(.horizontal, -16)
            
            Divider()
                .padding(.top)
        }
    }
}

struct CardSuggestionsViewModel_Previews: PreviewProvider {
    static var previews: some View {
        CardSuggestionsView(cardId: "11502550")
    }
}
