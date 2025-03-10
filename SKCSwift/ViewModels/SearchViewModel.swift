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
    @ObservationIgnored
    private(set) var recentlyViewedCardDetails = [Card]()
    @ObservationIgnored
    private var recentlyViewedCardInfo = [String: Card]()
    
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
                requestErrors[.search] = searchErr
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
    
    nonisolated private func partitionResults(newSearchResults newResults: [Card], previousSearchResultsCardIDs: Set<String>) async -> ([SearchResults]?, Set<String>) {
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
    
    func fetchRecentlyViewedDetails(recentlyViewed newHistory: [History]) async {
        let recentlyViewedCardIDs = Set(newHistory.map { $0.id })
        
        requestErrors[.recentlyViewed] = nil
        dataTaskStatus[.recentlyViewed] = .pending
        (recentlyViewedCardInfo, requestErrors[.recentlyViewed]) = await fetchRecentlyViewedDetails(newRecentlyViewed: recentlyViewedCardIDs,
                                                                                                    recentlyViewedCardInfo: recentlyViewedCardInfo)
        recentlyViewedCardDetails = newHistory.map{ recentlyViewedCardInfo[$0.id] }.compactMap{ $0 }
        dataTaskStatus[.recentlyViewed] = .done
    }
    
    /// Check if data is already retrieved. If so, why make another network request? Sets ensure order of recentlyViewed and previous data results don't matter
    /// If data for a particular card needs to be downloaded - make network call
    nonisolated private func fetchRecentlyViewedDetails(newRecentlyViewed: Set<String>,
                                                        recentlyViewedCardInfo: [String: Card]) async -> ([String: Card], NetworkError?) {
        if newRecentlyViewed != Set(recentlyViewedCardInfo.values.map { $0.cardID })  {
            switch await data(cardDetailsUrl(), reqBody: BatchCardRequest(cardIDs: newRecentlyViewed),
                              resType: CardDetailsResponse.self, httpMethod: "POST") {
            case .success(let cardDetails):
                return (cardDetails.cardInfo, nil)
            case .failure(let error):
                return ([:], error)
            }
        }
        return (recentlyViewedCardInfo, nil)
    }
}

enum SearchModelDataType: CaseIterable {
    case search, recentlyViewed
}
