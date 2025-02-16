//
//  CardSearchViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import Foundation

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
    private(set) var recentlyBrowsedDetails = [Card]()
    
    @MainActor
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
            dataTaskStatus = .pending
            
            task = Task {
                switch await data(searchCardURL(cardName: newValue.trimmingCharacters(in: .whitespacesAndNewlines)), resType: [Card].self) {
                case .success(let cards):
                    if cards.isEmpty {
                        searchResults.removeAll()
                        searchResultsIds.removeAll()
                        requestError = .notFound
                    } else {
                        let (sections, searchResultsIds, results, shouldUpdateUI) = await partitionResults(cards)
                        if (shouldUpdateUI) {
                            searchResults.removeAll()
                            self.searchResultsIds = searchResultsIds
                            for section in sections {
                                searchResults.append(SearchResults(section: section, results: results[section]!))
                            }
                        }
                    }
                case .failure(let error):
                    requestError = error
                }
                dataTaskStatus = .done
            }
        }
    }
    
    @MainActor
    func fetchRecentlyBrowsedDetails(recentlyBrowsed: [History]) async {
        let body = CardDetailsRequest(cardIDs: recentlyBrowsed.map { $0.id })
        
        switch await data(cardDetailsUrl(), reqBody: body, resType: CardDetailsResponse.self, httpMethod: "POST") {
        case .success(let cardDetails):
            recentlyBrowsedDetails = recentlyBrowsed.map{ cardDetails.cardInfo[$0.id] }.compactMap{ $0 }
        case .failure(_): break
        }
    }
    
    private func partitionResults(_ cards: [Card]) async -> ([String], [String],  [String : [Card]], Bool) {
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
