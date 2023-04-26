//
//  CardSearchViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import Foundation

@MainActor
class CardSearchViewModel: ObservableObject {
    @Published private(set) var searchResults = [SearchResults]()
    @Published private(set) var searchResultsIds = [String]()
    @Published var searchText = ""
    @Published private(set) var isFetching = false
    @Published private(set) var task: URLSessionDataTask?
    
    func newSearchSubject(value: String) {
        if (isFetching) {
            task?.cancel()
        }
        
        if (value == "") {
            self.searchResults = []
            self.searchResultsIds = []
            self.isFetching = false
            self.task = nil
        } else {
            isFetching = true
            task = searchCard(searchTerm: value.trimmingCharacters(in: .whitespacesAndNewlines), {result in
                
                DispatchQueue.main.async {
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
                    case .failure: break    // TODO add error screen for appropriate error response
                    }
                    
                    self.isFetching = false
                }
            })
        }
    }
}
