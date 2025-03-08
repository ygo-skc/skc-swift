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
    
    private(set) var dataTaskStatus: [SearchModelDataType: DataTaskStatus] = Dictionary(uniqueKeysWithValues: SearchModelDataType.allCases.map { ($0, .uninitiated) })
    private(set) var requestErrors = [SearchModelDataType: NetworkError?]()
    
    @ObservationIgnored
    private(set) var searchResults = [SearchResults]()
    @ObservationIgnored
    private var cardIDsForSearchResults: Set<String> = []
    @ObservationIgnored
    private var searchTask: Task<(), any Error>?
    
    // recently browsed state
    private(set) var recentlyViewedCardInfo = [String: Card]()
    private(set) var recentlyViewedSuggestions: [CardReference] = []
    
    func searchDB(oldValue: String, newValue: String) async {
        if requestErrors[.search] == .notFound && newValue.starts(with: oldValue) {
            return
        }
        
        searchTask?.cancel()
        if newValue == "" {
            resetSearchResults()
            requestErrors[.search] = nil
            dataTaskStatus[.search] = .done
        } else {
            searchTask = Task {
                requestErrors[.search] = nil
                dataTaskStatus[.search] = .pending
                
                let (requestResults, searchErr) = await search(subject: newValue)
                if requestResults.isEmpty || searchErr != nil {
                    requestErrors[.search] = searchErr
                    resetSearchResults()
                } else {
                    let (newSearchResults, newSearchResultsCardIDs) = await partitionResults(newSearchResults: requestResults,
                                                                                             previousSearchResultsCardIDs: cardIDsForSearchResults)
                    if let newSearchResults {
                        searchResults = newSearchResults
                        cardIDsForSearchResults = newSearchResultsCardIDs
                    }
                }
                dataTaskStatus[.search] = .done
            }
        }
    }
    
    private func resetSearchResults() {
        cardIDsForSearchResults.removeAll()
        searchResults.removeAll()
    }
    
    nonisolated private func search(subject: String) async -> ([Card], NetworkError?) {
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
    
    func fetchHistoryData(recentlyViewed newHistory: [History]) async {
        let newRecentlyViewed = Set(newHistory.map { $0.id })
        
        if newRecentlyViewed != Set(recentlyViewedCardInfo.keys) {
            await withTaskGroup(of: Void.self) { taskGroup in
                taskGroup.addTask { @Sendable in await self.fetchRecentlyViewedDetails(newRecentlyViewed: newRecentlyViewed) }
                taskGroup.addTask { @Sendable in await self.fetchRecentlyViewedSuggestions(newRecentlyViewed: newRecentlyViewed) }
            }
        }
    }
    
    func fetchRecentlyViewedDetails(newRecentlyViewed: Set<String>) async {
        requestErrors[.recentlyViewed] = nil
        dataTaskStatus[.recentlyViewed] = .pending
        (recentlyViewedCardInfo, requestErrors[.recentlyViewed]) = await fetchRecentlyViewedDetails(newRecentlyViewed: newRecentlyViewed)
        dataTaskStatus[.recentlyViewed] = .done
    }
    
    /// Check if data is already retrieved. If so, why make another network request? Sets ensure order of recentlyViewed and previous data results don't matter
    /// If data for a particular card needs to be downloaded - make network call
    nonisolated private func fetchRecentlyViewedDetails(newRecentlyViewed: Set<String>) async -> ([String: Card], NetworkError?) {
        switch await data(cardDetailsUrl(), reqBody: BatchCardRequest(cardIDs: newRecentlyViewed),
                          resType: CardDetailsResponse.self, httpMethod: "POST") {
        case .success(let cardDetails):
            return (cardDetails.cardInfo, nil)
        case .failure(let error):
            return ([:], error)
        }
    }
    
    func fetchRecentlyViewedSuggestions(newRecentlyViewed: Set<String>) async {
        recentlyViewedSuggestions = await fetchRecentlyViewedSuggestions(newRecentlyViewed: newRecentlyViewed)
    }
    
    nonisolated private func fetchRecentlyViewedSuggestions(newRecentlyViewed: Set<String>) async -> [CardReference] {
        switch await data(batchCardSuggestionsURL(), reqBody: BatchCardRequest(cardIDs: newRecentlyViewed),
                          resType: BatchSuggestions.self, httpMethod: "POST") {
        case .success(let suggestions):
            let s = suggestions.namedMaterials + suggestions.namedReferences
            return Array(s
                .reduce(into: [String: CardReference]()) { accumulator, ref in
                    accumulator[ref.card.cardID] = ref
                }
                .values
                .sorted(by: { $0.occurrences > $1.occurrences })
                .prefix(8))
        default: break
        }
        return []
    }
}

enum SearchModelDataType: CaseIterable {
    case search, recentlyViewed
}
