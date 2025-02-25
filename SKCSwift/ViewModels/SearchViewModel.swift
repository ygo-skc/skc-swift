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
                return (results, err)
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

fileprivate final actor TrendingResultsActor {
    private var recentlyViewedCardInfo = [String: Card]()
    
    fileprivate func fetchRecentlyViewedDetails(newCardIDs newRecentlyViewed: [String]) async -> ([Card], NetworkError?){
        if let body = recentlyViewedRequestBody(newRecentlyViewed: newRecentlyViewed) {
            switch await data(cardDetailsUrl(), reqBody: body, resType: CardDetailsResponse.self, httpMethod: "POST") {
            case .success(let cardDetails):
                recentlyViewedCardInfo = cardDetails.cardInfo
                return (newRecentlyViewed.map{ cardDetails.cardInfo[$0] }.compactMap{ $0 }, nil)
            case .failure(let error):
                return ([], error)
            }
        }
        return (newRecentlyViewed.map{ recentlyViewedCardInfo[$0] }.compactMap{ $0 }, nil)
    }
    
    /// Check if data is already retrieved. If so, why make another network request? Sets ensure order of recentlyViewed and previous data results don't matter
    private func recentlyViewedRequestBody(newRecentlyViewed: [String]) -> CardDetailsRequest? {
        let newRecentlyViewedSet = Set(newRecentlyViewed)
        if newRecentlyViewedSet != Set(recentlyViewedCardInfo.values.map { $0.cardID })  {
            return CardDetailsRequest(cardIDs: newRecentlyViewedSet)
        }
        return nil
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
    private let trendingResultsActor = TrendingResultsActor()
    private(set) var recentlyViewedCardDetails = [Card]()
    
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
        (recentlyViewedCardDetails, requestErrors[.recentlyViewed]) = await trendingResultsActor.fetchRecentlyViewedDetails(newCardIDs: recentlyViewedCardIDs)
        dataTaskStatus[.recentlyViewed] = .done
    }
}

enum SearchModelDataType: CaseIterable {
    case search, recentlyViewed
}
