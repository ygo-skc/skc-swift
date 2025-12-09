//
//  CardSearchViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import Foundation

@Observable
final class SearchViewModel {
    var isSearching = false // user has search open
    var searchText = ""
    
    private(set) var requestError: NetworkError? = nil
    private(set) var dataTaskStatus: DataTaskStatus = .pending
    private(set) var isSearchSlow = false
    
    @ObservationIgnored
    private(set) var searchResults = [SearchResults]()
    @ObservationIgnored
    private var cardIDsForSearchResults: Set<String> = []
    @ObservationIgnored
    private var searchTask: Task<(), any Error>?
    @ObservationIgnored
    private var slowSearchDispatch: DispatchWorkItem?
    
    func searchDB(oldValue: String, newValue: String) async {
        if requestError == .notFound && newValue.starts(with: oldValue) {
            return
        }
        
        searchTask?.cancel()
        slowSearchDispatch?.cancel()
        if newValue == "" {
            resetSearchResults()
            requestError = nil
            dataTaskStatus = .done
        } else {
            searchTask = Task {
                dataTaskStatus = .pending
                slowSearchDispatch = DispatchWorkItem { [weak self] in
                    self?.isSearchSlow = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: slowSearchDispatch!)
                
                let (requestResults, searchErr, searchTaskStatus) = await search(subject: newValue)
                if Task.isCancelled {
                    return
                }
                if requestResults.isEmpty || searchErr != nil || searchErr == .notFound {
                    resetSearchResults()
                } else {
                    let (newSearchResults, newSearchResultsCardIDs) = await partitionResults(newSearchResults: requestResults,
                                                                                             previousSearchResultsCardIDs: cardIDsForSearchResults)
                    if let newSearchResults {
                        searchResults = newSearchResults
                        cardIDsForSearchResults = newSearchResultsCardIDs
                    }
                }
                slowSearchDispatch?.cancel()
                isSearchSlow = false
                requestError = searchErr
                dataTaskStatus = searchTaskStatus
            }
        }
    }
    
    private func resetSearchResults() {
        cardIDsForSearchResults.removeAll()
        searchResults.removeAll()
    }
    
    @concurrent
    nonisolated private func search(subject: String) async -> ([Card], NetworkError?, DataTaskStatus) {
        let res = await data(searchCardURL(cardName: subject.trimmingCharacters(in: .whitespacesAndNewlines)), resType: [Card].self)
        let cards = (try? res.get()) ?? []  // on error hard code results to empty list
        let (networkError, taskStatus) = res.validate()
        return (cards, (cards.isEmpty && networkError == nil) ? .notFound : networkError, taskStatus)   // if empty results list returned w/ no errors, treat it as not found
    }
    
    @concurrent
    nonisolated private func partitionResults(newSearchResults newResults: [Card],
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
