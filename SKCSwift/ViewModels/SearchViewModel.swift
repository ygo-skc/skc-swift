//
//  CardSearchViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import Foundation

fileprivate final actor SearchResultsActor {
    private var cardIDs: Set<String> = []
    private var results: [SearchResults] = []
    private var task: Task<([SearchResults], NetworkError?), any Error>?
    
    fileprivate func search(newValue: String) async -> ([SearchResults], NetworkError?) {
        task?.cancel()
        if newValue == "" {
            async let _ = reset()
            return ([], nil)
        }
        
        task = Task {
            switch await data(searchCardURL(cardName: newValue.trimmingCharacters(in: .whitespacesAndNewlines)), resType: [Card].self) {
            case .success(let cards):
                if cards.isEmpty {
                    async let _ = reset()
                    return ([], NetworkError.notFound)
                }
                await partitionResults(newSearchResults: cards)
                return (results, nil)
            case .failure(let err):
                return ([], err)
            }
        }
        return try! await task?.value ?? (results, nil)
    }
    
    private func reset() async {
        cardIDs.removeAll()
        results.removeAll()
    }
    
    private func partitionResults(newSearchResults newResults: [Card]) async {
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
        
        if self.cardIDs != cardIDs {
            results = sections.map { SearchResults(section: $0, results: newResultsByCardID[$0]!) }
        }
    }
}

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
    private let searchResultsActor = SearchResultsActor()
    
    // recently browsed state
    @ObservationIgnored
    private(set) var recentlyViewedCardDetails = [Card]()
    private var recentlyViewedCardInfo = [String: Card]()
    
    func newSearchSubject(oldValue: String,newValue: String) async {
        if requestErrors[.search] == .notFound && newValue.starts(with: oldValue) {
            return
        }
        
        requestErrors[.search] = nil
        dataTaskStatus[.search] = .pending
        (searchResults, requestErrors[.search]) = await searchResultsActor.search(newValue: newValue)
        dataTaskStatus[.search] = .done
    }
    
    func fetchRecentlyViewedDetails(recentlyViewed newHistory: [History]) async {
        let recentlyViewedCardIDs = newHistory.map { $0.id }
        
        requestErrors[.recentlyViewed] = nil
        dataTaskStatus[.recentlyViewed] = .pending
        (recentlyViewedCardInfo, requestErrors[.recentlyViewed]) = await fetchRecentlyViewedDetails(newRecentlyViewed: recentlyViewedCardIDs,
                                                                                                    recentlyViewedCardInfo: recentlyViewedCardInfo)
        recentlyViewedCardDetails = newHistory.map{ recentlyViewedCardInfo[$0.id] }.compactMap{ $0 }
        dataTaskStatus[.recentlyViewed] = .done
    }
    
    /// Check if data is already retrieved. If so, why make another network request? Sets ensure order of recentlyViewed and previous data results don't matter
    /// If data for a particular card needs to be downloaded - make network call
    nonisolated private func fetchRecentlyViewedDetails(newRecentlyViewed: [String], recentlyViewedCardInfo: [String: Card]) async -> ([String: Card], NetworkError?) {
        let newRecentlyViewedSet = Set(newRecentlyViewed)
        if newRecentlyViewedSet != Set(recentlyViewedCardInfo.values.map { $0.cardID })  {
            switch await data(cardDetailsUrl(), reqBody: CardDetailsRequest(cardIDs: newRecentlyViewedSet), resType: CardDetailsResponse.self, httpMethod: "POST") {
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
