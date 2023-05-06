//
//  CardSuggestionsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/29/23.
//

import SwiftUI

struct CardSuggestionsView: View {
    var cardID: String
    
    @State private(set) var hasSelfReference: Bool = false
    @State private(set) var namedMaterials: [CardReference] = [CardReference]()
    @State private(set) var namedReferences: [CardReference] = [CardReference]()
    @State private(set) var isDataLoaded = false
    
    var body: some View {
        SectionView(header: "Suggestions",
                    disableDestination: true,
                    variant: .plain,
                    destination: {EmptyView()},
                    content: {
            VStack(alignment: .leading, spacing: 5) {
                if !isDataLoaded {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Other cards that have a tie of sorts with currently selected card. These could be summoning materials for example.")
                        .fontWeight(.light)
                        .padding(.bottom)
                    if (namedMaterials.isEmpty && namedReferences.isEmpty) {
                        Text("Nothing here 🤔")
                            .font(.headline)
                            .fontWeight(.regular)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom)
                    } else {
                        NamedSuggestionsView(header: "Named Materials", references: namedMaterials)
                        NamedSuggestionsView(header: "Named References", references: namedReferences)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .onAppear {
                if isDataLoaded {
                    return
                }
                
                request(url: cardSuggestionsURL(cardID: cardID)) { (result: Result<CardSuggestions, Error>) -> Void in
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
        })
    }
}

private struct NamedSuggestionsView: View {
    var header: String
    var references: [CardReference]
    
    var body: some View {
        if (!references.isEmpty) {
            Text(header)
                .font(.title3)
                .fontWeight(.medium)
                .padding(.bottom)
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 15) {
                    ForEach(references, id: \.card.cardID) { suggestion in
                        SuggestedCardView(card: suggestion.card, occurrence: suggestion.occurrences)
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
        CardSuggestionsView(cardID: "11502550")
            .padding(.horizontal)
    }
}
