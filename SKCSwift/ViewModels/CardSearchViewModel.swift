//
//  SearchCardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct CardSearchViewModel: View {
    @State private var searchResults = [SearchResults]()
    @State private var searchResultsIds = [String]()
    @State private var searchText = ""
    @State private var isFetching = false
    @State private var task: URLSessionDataTask?
    
    func newSearchSubject(value: String) {
        if (isFetching) {
            task?.cancel()
        }
        
        if (value == "") {
            self.searchResults = []
            self.searchResultsIds = []
        } else {
            isFetching = true
            task = searchCard(searchTerm: value.trimmingCharacters(in: .whitespacesAndNewlines), {result in
                switch result {
                case .success(let cards):
                    var results = [String: [Card]]()
                    var sections = [String]()
                    var searchResultsIds = [String]()
                    
                    cards.forEach { card in
                        let section = card.cardColor
                        if results[section] == nil {
                            results[section] = []
                            sections.append(section)
                        }
                        results[section]!.append(card)
                        searchResultsIds.append(card.cardID)
                    }
                    
                    if (self.searchResultsIds.count != searchResultsIds.count || self.searchResultsIds != searchResultsIds) {
                        var searchResults = [SearchResults]()
                        for (section) in sections {
                            searchResults.append(SearchResults(section: section, results: results[section]!))
                        }
                        
                        self.searchResults = searchResults
                        self.searchResultsIds = searchResultsIds
                    }
                case .failure(let error):
                    print(error)
                }
                
                isFetching = false
            })
        }
        
        
    }
    
    var body: some View {
        NavigationStack {
            if (!isFetching && !searchText.isEmpty && searchResults.isEmpty) {
                VStack {
                    Spacer()
                    Text("Nothing found in database")
                        .font(.title2)
                }
                .padding(.horizontal)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
            } else if (searchText.isEmpty) {
                VStack(alignment: .leading) {
                    Text("Suggestions")
                        .font(.title2)
                }
                .padding(.all)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
            }
            
            List(searchResults) { sr in
                Section(header: HStack{
                    Circle()
                        .foregroundColor(cardColorUI(cardColor: sr.section))
                        .frame(width: 15)
                    Text(sr.section)
                }
                    .font(.headline)
                    .fontWeight(.black) ) {
                        ForEach(sr.results, id: \.cardID) { card in
                            VStack {
                                NavigationLink(destination: CardSearchLinkDestination(cardId: card.cardID), label: {
                                    CardSearchResultViewModel(cardId: card.cardID, cardName: card.cardName, monsterType: card.monsterType)
                                })
                            }
                        }
                    }
            }
            .listStyle(.plain)
            .navigationTitle("Search")
            .searchable(text: self.$searchText, prompt: "Search for card...")
            .disableAutocorrection(true)
            .onChange(of: searchText, perform: newSearchSubject)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .ignoresSafeArea(.keyboard)
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

struct CardSearchLinkDestination: View {
    var cardId: String
    
    var body: some View {
        CardViewModel(cardId: cardId)
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct SearchCardViewModel_Previews: PreviewProvider {
    static var previews: some View {
        CardSearchViewModel()
        CardSearchLinkDestination(cardId: "40044918")
    }
}
