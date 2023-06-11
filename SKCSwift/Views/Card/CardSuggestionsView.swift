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
    @State private(set) var isSuggestionDataLoaded = false
    
    @State private(set) var referencedBy: [Card] = [Card]()
    @State private(set) var materialFor: [Card] = [Card]()
    @State private(set) var isSupportDataLoaded = false
    
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
                    disableDestination: true,
                    variant: .plain,
                    destination: {EmptyView()},
                    content: {
            LazyVStack(alignment: .leading, spacing: 5) {
                if isSuggestionDataLoaded || isSupportDataLoaded {
                    Text("Other cards that have a tie of sorts with currently selected card. These could be summoning materials for example.")
                        .fontWeight(.light)
                        .padding(.bottom)
                    if namedMaterials.isEmpty && namedReferences.isEmpty && referencedBy.isEmpty && materialFor.isEmpty {
                        Text("Nothing here 🤔")
                            .font(.headline)
                            .fontWeight(.regular)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom)
                    } else {
                        SuggestionView(header: "Named Materials", references: namedMaterials)
                        SuggestionView(header: "Named References", references: namedReferences)
                        SupportView(header: "Referenced By", references: referencedBy)
                        SupportView(header: "Material For", references: materialFor)
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

private struct SuggestionView: View {
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

private struct SupportView: View {
    var header: String
    var references: [Card]
    
    var body: some View {
        if (!references.isEmpty) {
            Text(header)
                .font(.title3)
                .fontWeight(.medium)
                .padding(.bottom)
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 15) {
                    ForEach(references, id: \.cardID) { card in
                        NavigationLink(destination: CardSearchLinkDestination(cardID: card.cardID), label: {
                            YGOCardView(card: card, isDataLoaded: true, variant: .condensed)
                                .contentShape(Rectangle())
                        })
                        .buttonStyle(PlainButtonStyle())
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
