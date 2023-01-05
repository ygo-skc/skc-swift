//
//  SearchCardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct CardSearchViewModel: View {
    @State var searchResults: [Card] = []
    @State var searchText = ""
    
    var body: some View {
        NavigationStack {
            List(searchResults, id: \.cardID) { card in
                NavigationLink(destination: CardSearchLinkDestination(cardId: card.cardID), label: {
                    CardSearchResultsViewModel(cardName: card.cardName, monsterType: card.monsterType)
                })
            }.listStyle(.plain).searchable(text: self.$searchText, prompt: "Search cards...")
                .onChange(of: searchText) { value in
                    searchCard(searchTerm: value.trimmingCharacters(in: .whitespacesAndNewlines), {result in
                        switch result {
                        case .success(let card):
                            self.searchResults = card
                        case .failure(let error):
                            print(error)
                        }
                    })
                }.navigationTitle("Search")
            
        }
    }
}

struct CardSearchLinkDestination: View {
    var cardId: String
    
    var body: some View {
        CardViewModel(cardId: cardId).navigationBarTitleDisplayMode(.inline)
    }
}

struct CardSearchResultsViewModel: View {
    var cardName: String
    var monsterType: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(cardName).fontWeight(.bold).font(.footnote)
            if (monsterType != nil) {
                Text(monsterType!).fontWeight(.light).font(.footnote)
            }
        }
    }
}

struct SearchCardViewModel_Previews: PreviewProvider {
    static var previews: some View {
                CardSearchViewModel()
//        CardSearchLinkDestination(cardId: "")
    }
}
