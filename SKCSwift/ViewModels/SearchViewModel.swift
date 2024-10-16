//
//  CardSearchViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import Foundation

@Observable
class SearchViewModel {
    var searchText: String = ""
    
    private(set) var status: DataTaskStatus?
    
    @ObservationIgnored
    private(set) var searchResults = [SearchResults]()
    
    @ObservationIgnored
    private var searchResultsIds = [String]()
    @ObservationIgnored
    private var task: Task<(), any Error>?
    
    @MainActor
    func newSearchSubject(value: String) async {
        if let task {
            task.cancel()
        }
        
        if value == "" {
            self.task = nil
            self.searchResults.removeAll()
            self.searchResultsIds.removeAll()
            self.status = .done
        } else {
            self.status = .pending
            
            task = Task {
                switch await data([Card].self, url: searchCardURL(cardName: value.trimmingCharacters(in: .whitespacesAndNewlines))) {
                case .success(let cards):
                    if cards.isEmpty {
                        self.searchResults.removeAll()
                        self.searchResultsIds.removeAll()
                        self.status = .done
                        return
                    }
                    
                    let (sections, searchResultsIds, results, shouldUpdateUI) = await partitionResults(cards)
                    if (shouldUpdateUI) {
                        self.searchResults.removeAll()
                        self.searchResultsIds = searchResultsIds
                        for section in sections {
                            self.searchResults.append(SearchResults(section: section, results: results[section]!))
                        }
                    }
                    
                    self.status = .done
                case .failure(let error):
                    switch error {
                    case NetworkError.cancelled: break    // do nothing
                    default:
                        print(error)
                        self.status = .error
                    }
                }
            }
        }
    }
    
    nonisolated private func partitionResults(_ cards: [Card]) async -> ([String], [String],  [String : [Card]], Bool) {
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
        
        let shouldUpdateUI = self.searchResultsIds.count != searchResultsIds.count || self.searchResultsIds != searchResultsIds
        return (sections, searchResultsIds, results, shouldUpdateUI)
    }
}
