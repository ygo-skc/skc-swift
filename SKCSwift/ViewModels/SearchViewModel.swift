//
//  CardSearchViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import Foundation

class SearchViewModel: ObservableObject {
    @Published private(set) var searchResults = [SearchResults]()
    @Published private(set) var searchResultsIds = [String]()
    @Published private(set) var isFetching = false
    @Published private(set) var task: URLSessionDataTask?
    @Published var searchText = ""
    
    func newSearchSubject(value: String) {
        if (isFetching) {
            Task(priority: .background) {
                task?.cancel()
            }
        }
        
        if (value == "") {
            Task(priority: .background) {
                self.task = nil
                await self.updateState(searchResults: [], searchResultsIds: [])
            }
        } else {
            isFetching = true
            task = requestTask(url: searchCardURL(cardName: value.trimmingCharacters(in: .whitespacesAndNewlines)), priority: 0.45, { (result: Result<[Card], Error>) -> Void in
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
                        Task(priority: .background) { [searchResults, searchResultsIds] in
                            await self.updateState(searchResults: searchResults, searchResultsIds: searchResultsIds)
                        }
                    }
                case .failure: break    // TODO add error screen for appropriate error response
                }
            })
        }
    }
    
    @MainActor
    func updateState(searchResults: [SearchResults], searchResultsIds: [String]) {
        self.searchResults = searchResults
        self.searchResultsIds = searchResultsIds
        self.isFetching = false
    }
}
