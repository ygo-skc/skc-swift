//
//  CardSearchViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import Foundation

@Observable
class SearchViewModel {
    private(set) var status = DataTaskStatus.pending
    
    private(set) var searchResults = [SearchResults]()
    private(set) var searchResultsIds = [String]()
    
    @ObservationIgnored
    private var task: URLSessionDataTask?
    
    func newSearchSubject(value: String) async {
        if let task {
            Task(priority: .userInitiated) {
                task.cancel()
            }
        }
        
        if value == "" {
            self.task = nil
            Task(priority: .userInitiated) {
                self.searchResults = []
                self.searchResultsIds = []
                await self.updateState()
            }
        } else {
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
                        
                        self.searchResults = searchResults
                        self.searchResultsIds = searchResultsIds
                        Task(priority: .userInitiated) {
                            await self.updateState()
                        }
                    }
                case .failure: break    // TODO add error screen for appropriate error response
                }
            })
        }
    }
    
    @MainActor
    func updateState() {
        self.status = .done
    }
}
