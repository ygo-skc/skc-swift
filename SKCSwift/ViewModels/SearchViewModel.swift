//
//  CardSearchViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import Foundation

@Observable
class SearchViewModel {
    private(set) var status = DataTaskStatus.done
    
    @ObservationIgnored
    private(set) var searchResults = [SearchResults]()
    
    @ObservationIgnored
    private var searchResultsIds = [String]()
    @ObservationIgnored
    private var task: Task<(), any Error>?
    
    func newSearchSubject(value: String) async {
        if let task {
            task.cancel()
        }
        
        if value == "" {
            self.task = nil
            self.searchResults.removeAll()
            self.searchResultsIds.removeAll()
            self.updateState(.done)
        } else {
            self.updateState(.pending)
            
            task = Task {
                do {
                    let cards = try await data([Card].self, url: searchCardURL(cardName: value.trimmingCharacters(in: .whitespacesAndNewlines)))
                    if cards.isEmpty {
                        self.searchResults.removeAll()
                        self.searchResultsIds.removeAll()
                        self.updateState(.done)
                        return
                    }
                    
                    var sections = [String]()
                    var searchResultsIds = [String]()
                    let results = cards.reduce(into: [String: [Card]]()) { results, card in
                        let section = card.cardColor
                        results[section, default: []].append(card)
                        if !sections.contains(section) {
                            sections.append(section)
                        }
                        searchResultsIds.append(card.cardID)
                    }
                    
                    if (self.searchResultsIds.count != searchResultsIds.count || self.searchResultsIds != searchResultsIds) {
                        self.searchResults.removeAll()
                        self.searchResultsIds = searchResultsIds
                        for section in sections {
                            self.searchResults.append(SearchResults(section: section, results: results[section]!))
                        }
                        
                        self.updateState(.done)
                    }
                } catch {
                    print(error)
                    self.updateState(.error)
                }
            }
        }
    }
    
    private func updateState(_ status: DataTaskStatus) {
        Task(priority: .userInitiated) { @MainActor in
            self.status = status
        }
    }
}
