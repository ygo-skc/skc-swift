//
//  CardSearchViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import Foundation

@MainActor
@Observable
final class SearchViewModel {
    var isSearching = false
    var searchText = ""
    
    private(set) var requestError: NetworkError? = nil
    private(set) var dataTaskStatus: DataTaskStatus = .uninitiated
    
    private(set) var searchResults = [SearchResults]()
    @ObservationIgnored
    private var cardIDsForSearchResults: Set<String> = []
    @ObservationIgnored
    private var searchTask: Task<(), any Error>?
    
    func searchDB(oldValue: String, newValue: String) async {
        if requestError == .notFound && newValue.starts(with: oldValue) {
            return
        }
        
        searchTask?.cancel()
        if newValue == "" {
            resetSearchResults()
            requestError = nil
            dataTaskStatus = .done
        } else {
            searchTask = Task {
                requestError = nil
                dataTaskStatus = .pending
                
                let (requestResults, searchErr) = await search(subject: newValue)
                requestError = searchErr
                if requestResults.isEmpty || searchErr != nil {
                    resetSearchResults()
                } else {
                    let (newSearchResults, newSearchResultsCardIDs) = await partitionResults(newSearchResults: requestResults,
                                                                                             previousSearchResultsCardIDs: cardIDsForSearchResults)
                    if let newSearchResults {
                        searchResults = newSearchResults
                        cardIDsForSearchResults = newSearchResultsCardIDs
                    }
                }
                dataTaskStatus = .done
            }
        }
    }
    
    private func resetSearchResults() {
        cardIDsForSearchResults.removeAll()
        searchResults.removeAll()
    }
    
    @concurrent
    private func search(subject: String) async -> ([Card], NetworkError?) {
        switch await data(searchCardURL(cardName: subject.trimmingCharacters(in: .whitespacesAndNewlines)), resType: [Card].self) {
        case .success(let cards):
            if cards.isEmpty {
                return ([], NetworkError.notFound)
            }
            return (cards, nil)
        case .failure(let err):
            return ([], err)
        }
    }
    
    @concurrent
    private func partitionResults(newSearchResults newResults: [Card],
                                              previousSearchResultsCardIDs: Set<String>) async -> ([SearchResults]?, Set<String>) {
        var sections: [String] = []
        var cardIDs: Set<String> = []
        
        let newResultsByCardID = newResults.reduce(into: [String: [Card]]()) { results, card in
            let section = card.cardColor
            results[section, default: []].append(card)
            if !sections.contains(section) {
                sections.append(section)
            }
            cardIDs.insert(card.cardID)
        }
        
        if previousSearchResultsCardIDs != cardIDs {
            return (sections.map { SearchResults(section: $0, results: newResultsByCardID[$0]!) }, cardIDs)
        }
        return (nil, cardIDs)
    }
}
