//
//  SearchCardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct CardSearchViewModel: View {
    @State var searchResults = [SearchResults]()
    @State var searchText = ""
    @State var isFetching = false
    
    var body: some View {
        NavigationStack {
            if (searchResults.isEmpty && !searchText.isEmpty && !isFetching) {
                Text("Nothing found in database")
                    .font(.title)
            } else if (searchText.isEmpty) {
                VStack(alignment: .leading) {
                    Text("Suggestions")
                        .font(.title)
                }.padding(.horizontal)
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
            }
            
            List(searchResults) { searchResults in
                Section(header: Text(searchResults.section) ) {
                    ForEach(searchResults.results, id: \.cardID) { card in
                        LazyVStack {
                            NavigationLink(destination: CardSearchLinkDestination(cardId: card.cardID), label: {
                                CardSearchResultsViewModel(cardId: card.cardID, cardName: card.cardName, monsterType: card.monsterType)
                            })
                        }
                    }
                }
            }.listStyle(.plain).searchable(text: self.$searchText, prompt: "Search cards...")
                .onChange(of: searchText) { value in
                    if (value == "") {
                        searchResults = []
                    } else {
                        isFetching = true
                        searchCard(searchTerm: value.trimmingCharacters(in: .whitespacesAndNewlines), {result in
                            switch result {
                            case .success(let cards):
                                var results = [String: [Card]]()
                                
                                cards.forEach { card in
                                    results[card.cardColor, default: []].append(card)
                                }
                                
                                var searchResults = [SearchResults]()
                                for (section, cards) in results {
                                    searchResults.append(SearchResults(section: section, results: cards))
                                }
                                self.searchResults = searchResults
                            case .failure(let error):
                                print(error)
                            }
                            
                            isFetching = false
                        })
                    }
                }.navigationTitle("Search")
            
        }
    }
}

struct SearchResults: Identifiable {
    var id = UUID()
    var section: String
    var results: [Card]
}

struct CardSearchLinkDestination: View {
    var cardId: String
    
    var body: some View {
        CardViewModel(cardId: cardId).navigationBarTitleDisplayMode(.inline)
    }
}

struct CardSearchResultsViewModel: View {
    var cardId: String
    var cardName: String
    var monsterType: String?
    
    var body: some View {
        HStack {
            RoundedImageViewModel(radius: 70, imageUrl: URL(string: "https://images.thesupremekingscastle.com/cards/x-sm/\(cardId).jpg")!)
            VStack(alignment: .leading) {
                Text(cardName).fontWeight(.bold).font(.footnote)
                if (monsterType != nil) {
                    Text(monsterType!).fontWeight(.light).font(.footnote)
                }
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
