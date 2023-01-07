//
//  SearchCardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct CardSearchViewModel: View {
    @State private var searchResults = [SearchResults]()
    @State private var searchText = ""
    @State private var isFetching = false
    
    var body: some View {
        NavigationStack {
            if (!isFetching && !searchText.isEmpty && searchResults.isEmpty) {
                VStack {
                    Spacer()
                    Text("Nothing found in database")
                        .font(.title2)
                }.padding(.horizontal)
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .center
                    )
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
            
            List(searchResults) { sr in
                Section(header: Text(sr.section).font(.headline).fontWeight(.black) ) {
                    ForEach(sr.results, id: \.cardID) { card in
                        LazyVStack {
                            NavigationLink(destination: CardSearchLinkDestination(cardId: card.cardID), label: {
                                CardSearchResultsViewModel(cardId: card.cardID, cardName: card.cardName, monsterType: card.monsterType)
                            })
                        }
                    }
                }
            }.listStyle(.plain)
                .searchable(text: self.$searchText, prompt: "Search for card...")
                .onChange(of: searchText) { value in
                    if (value == "") {
                        searchResults = []
                    } else {
                        isFetching = true
                        searchCard(searchTerm: value.trimmingCharacters(in: .whitespacesAndNewlines), {result in
                            switch result {
                            case .success(let cards):
                                var results = [String: [Card]]()
                                var sections = [String]()
                                
                                cards.forEach { card in
                                    let section = card.cardColor
                                    if results[section] == nil {
                                        results[section] = []
                                        sections.append(section)
                                    }
                                    results[section]!.append(card)
                                }
                                
                                var searchResults = [SearchResults]()
                                for (section) in sections {
                                    searchResults.append(SearchResults(section: section, results: results[section]!))
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
            RoundedImageViewModel(radius: 60, imageUrl: URL(string: "https://images.thesupremekingscastle.com/cards/tn/\(cardId).jpg")!)
            VStack(alignment: .leading) {
                Text(cardName).fontWeight(.bold).font(.footnote)
                if (monsterType != nil) {
                    Text(monsterType!).fontWeight(.light).font(.footnote)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SearchCardViewModel_Previews: PreviewProvider {
    static var previews: some View {
        CardSearchViewModel()
        CardSearchResultsViewModel(cardId: "40044918", cardName: "Elemental HERO Stratos", monsterType: "Warrior/Effect")
    }
}
