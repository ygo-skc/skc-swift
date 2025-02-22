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
    
    private(set) var dataTaskStatus = DataTaskStatus.uninitiated
    private(set) var requestError: NetworkError?
    
    @ObservationIgnored
    private(set) var searchResults = [SearchResults]()
    
    @ObservationIgnored
    private var searchResultsIds = [String]()
    @ObservationIgnored
    private var task: Task<(), any Error>?
    
    // recently browsed state
    private(set) var recentlyViewedCardDetailsResponse: CardDetailsResponse?
    private(set) var recentlyViewedCardDetails = [Card]()
    
    func newSearchSubject(oldValue: String, newValue: String) async {
        if requestError != .notFound || (requestError == .notFound && oldValue.count > newValue.count) {
            requestError = nil
        }
        
        if let task {
            task.cancel()
        }
        
        if newValue == "" {
            task = nil
            searchResults.removeAll()
            searchResultsIds.removeAll()
        } else {
            task = Task {
                dataTaskStatus = .pending
                switch await data(searchCardURL(cardName: newValue.trimmingCharacters(in: .whitespacesAndNewlines)), resType: [Card].self) {
                case .success(let cards):
                    if cards.isEmpty {
                        searchResults.removeAll()
                        searchResultsIds.removeAll()
                        requestError = .notFound
                    } else {
                        let (searchResultsIds, searchResults, shouldUpdateUI) = await partitionResults(newSearchResults: cards,
                                                                                                       previousResultsIDs: searchResultsIds)
                        if shouldUpdateUI {
                            self.searchResultsIds = searchResultsIds
                            self.searchResults = searchResults
                        }
                    }
                case .failure(let error):
                    requestError = error
                }
                dataTaskStatus = .done
            }
        }
    }
    
    func fetchRecentlyViewedDetails(recentlyViewed newHistory: [History]) async {
        if let body = recentlyViewedRequestBody(newHistory: newHistory, previousCardDetails: recentlyViewedCardDetails) {
            switch await data(cardDetailsUrl(), reqBody: body, resType: CardDetailsResponse.self, httpMethod: "POST") {
            case .success(let cardDetails):
                recentlyViewedCardDetailsResponse = cardDetails
                recentlyViewedCardDetails = newHistory.map{ cardDetails.cardInfo[$0.id] }.compactMap{ $0 }
            case .failure(_): break
            }
        }
    }
    
    /// Check if data is already retrieved. If so, why make another network request? Sets ensure order of recentlyViewed and previous data results don't matter
    private nonisolated func recentlyViewedRequestBody(newHistory: [History], previousCardDetails: [Card]) -> CardDetailsRequest? {
        let recentlyViewedCardIDs = newHistory.map { $0.id }
        if Set(recentlyViewedCardIDs) != Set(previousCardDetails.map { $0.cardID })  {
            return CardDetailsRequest(cardIDs: recentlyViewedCardIDs)
        }
        return nil
    }
    
    private nonisolated func partitionResults(newSearchResults: [Card], previousResultsIDs: [String]) async -> ([String], [SearchResults], Bool) {
        var sections = [String]()
        var searchResultsIds = [String]()
        let results = newSearchResults.reduce(into: [String: [Card]]()) { results, card in
            let section = card.cardColor
            results[section, default: []].append(card)
            if !sections.contains(section) {
                sections.append(section)
            }
            searchResultsIds.append(card.cardID)
        }
        
        let shouldUpdateUI = previousResultsIDs != searchResultsIds
        return (searchResultsIds, sections.map { SearchResults(section: $0, results: results[$0]!) }, shouldUpdateUI)
    }
}
