//
//  RecentlyViewedViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 3/16/25.
//

import Foundation

@MainActor
@Observable
final class RecentlyViewedViewModel {
    private(set) var requestError: NetworkError? = nil
    private(set) var dataTaskStatus: DataTaskStatus = .uninitiated
    
    private(set) var recentlyViewedCardDetails = [Card]()
    private(set) var recentlyViewedSuggestions: [CardReference] = []
    @ObservationIgnored
    private var recentlyViewedCardInfo = [String: Card]()
    
    func fetchRecentlyViewedDetails(recentlyViewed newHistory: [History]) async {
        let recentlyViewedCardIDs = Set(newHistory.map { $0.id })
        
        requestError = nil
        dataTaskStatus = .pending
        
        async let detailsAsync = fetchRecentlyViewedDetails(newRecentlyViewed: recentlyViewedCardIDs, recentlyViewedCardInfo: recentlyViewedCardInfo)
        async let suggestionAsync = fetchRecentlyViewedSuggestions(newlyViewed: recentlyViewedCardIDs)
        
        (recentlyViewedCardInfo, requestError) = await detailsAsync
        recentlyViewedSuggestions = await suggestionAsync
        recentlyViewedCardDetails = newHistory.map{ recentlyViewedCardInfo[$0.id] }.compactMap{ $0 }
        dataTaskStatus = .done
    }
    
    /// Check if data is already retrieved. If so, why make another network request? Sets ensure order of recentlyViewed and previous data results don't matter
    /// If data for a particular card needs to be downloaded - make network call
    @concurrent
    private func fetchRecentlyViewedDetails(newRecentlyViewed: Set<String>,
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
    
    @concurrent
    private func fetchRecentlyViewedSuggestions(newlyViewed: Set<String>) async  -> [CardReference] {
        async let suggestionAsync = fetchRecentlyViewedSuggestionData(newlyViewed: newlyViewed)
        async let supportAsync = fetchRecentlyViewedSupportData(newlyViewed: newlyViewed)

        return await consolidateSuggestions(suggestions: await suggestionAsync, support: await supportAsync)
    }
    
    @concurrent
    private func fetchRecentlyViewedSuggestionData(newlyViewed: Set<String>) async -> BatchSuggestions {
        switch await data(batchCardSuggestionsURL(), reqBody: BatchCardRequest(cardIDs: newlyViewed),
                          resType: BatchSuggestions.self, httpMethod: "POST") {
        case .success(let suggestions):
            return suggestions
        default: break
        }
        return BatchSuggestions(namedMaterials: [], namedReferences: [], materialArchetypes: Set(), referencedArchetypes: Set(),
                                unknownResources: Set(), falsePositives: Set())
    }
    
    @concurrent
    private func fetchRecentlyViewedSupportData(newlyViewed: Set<String>) async -> BatchSupport {
        switch await data(batchCardSupportURL(), reqBody: BatchCardRequest(cardIDs: newlyViewed),
                          resType: BatchSupport.self, httpMethod: "POST") {
        case .success(let suggestions):
            return suggestions
        default: break
        }
        return BatchSupport(referencedBy: [], materialFor: [], unknownResources: Set(), falsePositives: Set())
    }
    
    @concurrent
    private func consolidateSuggestions(suggestions: BatchSuggestions, support: BatchSupport) async -> [CardReference] {
        let s = suggestions.namedMaterials + suggestions.namedReferences + support.materialFor + support.referencedBy
        return Array(s
            .reduce(into: [String: CardReference]()) { accumulator, ref in
                accumulator[ref.card.cardID] = CardReference(occurrences: accumulator[ref.card.cardID]?.occurrences ?? 0 + ref.occurrences, card: ref.card)
            }
            .values
            .sorted(by: { $0.occurrences > $1.occurrences })
            .prefix(8))
    }
}
