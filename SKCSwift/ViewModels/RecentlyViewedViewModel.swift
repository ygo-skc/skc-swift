//
//  RecentlyViewedViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 3/16/25.
//

import Foundation

@Observable
final class RecentlyViewedViewModel {
    private(set) var dataTaskStatus: DataTaskStatus = .pending
    private(set) var requestError: NetworkError? = nil
    
    @ObservationIgnored
    private(set) var recentlyViewedCardDetails = [YGOCard]()
    @ObservationIgnored
    private(set) var recentlyViewedSuggestions: [CardReference] = []
    @ObservationIgnored
    private(set) var recentlyViewedArchetypeSuggestions: Set<String> = []
    @ObservationIgnored
    private var recentlyViewedCardInfo = [String: YGOCard]()
    
    func fetchRecentlyViewedDetails(recentlyViewed newHistory: [History]) async {
        let newRecentlyViewedSet = Set(newHistory.map { $0.id })
        
        (requestError, dataTaskStatus) = (nil, .pending)
        if !newHistory.isEmpty && newRecentlyViewedSet != Set(recentlyViewedCardInfo.values.map { $0.cardID }) {
            async let detailsAsync = fetchRecentlyViewedDetails(newRecentlyViewed: newRecentlyViewedSet,
                                                                recentlyViewedCardInfo: recentlyViewedCardInfo)
            async let suggestionAsync = fetchRecentlyViewedSuggestions(newlyViewed: newRecentlyViewedSet)
            
            var detailsTaskStatus: DataTaskStatus
            (recentlyViewedCardInfo, requestError, detailsTaskStatus) = await detailsAsync
            (recentlyViewedSuggestions, recentlyViewedArchetypeSuggestions) = await suggestionAsync
            recentlyViewedCardDetails = newHistory.map{ recentlyViewedCardInfo[$0.id] }.compactMap{ $0 }
            dataTaskStatus = detailsTaskStatus
        } else {
            recentlyViewedCardDetails = newHistory.map{ recentlyViewedCardInfo[$0.id] }.compactMap{ $0 }
            dataTaskStatus = .done
        }
    }
    
    @concurrent
    nonisolated private func fetchRecentlyViewedDetails(newRecentlyViewed: Set<String>,
                                                        recentlyViewedCardInfo: [String: YGOCard]) async -> ([String: YGOCard], NetworkError?, DataTaskStatus) {
        let res = await data(cardDetailsUrl(),
                             reqBody: BatchCardRequest(cardIDs: newRecentlyViewed),
                             resType: CardDetailsResponse.self, httpMethod: "POST")
        let cardData = (try? res.get().cardInfo) ?? recentlyViewedCardInfo
        let (error, status) = res.validate()
        return (cardData, error, status)
    }
    
    @concurrent
    nonisolated private func fetchRecentlyViewedSuggestions(newlyViewed: Set<String>) async  -> ([CardReference], Set<String>){
        async let suggestionAsync = fetchRecentlyViewedSuggestionData(newlyViewed: newlyViewed)
        async let supportAsync = fetchRecentlyViewedSupportData(newlyViewed: newlyViewed)
        
        let suggestions = await suggestionAsync
        let support = await supportAsync
        return (
            await consolidateSuggestions(suggestions: suggestions, support: support),
            Set(suggestions.materialArchetypes.union(suggestions.referencedArchetypes))
        )
    }
    
    @concurrent
    nonisolated private func fetchRecentlyViewedSuggestionData(newlyViewed: Set<String>) async -> BatchSuggestions {
        let data = await data(batchCardSuggestionsURL(), reqBody: BatchCardRequest(cardIDs: newlyViewed),
                              resType: BatchSuggestions.self, httpMethod: "POST")
        if case .success(let suggestions) = data {
            return suggestions
        }
        return BatchSuggestions(namedMaterials: [],
                                namedReferences: [],
                                materialArchetypes: Set(),
                                referencedArchetypes: Set(),
                                unknownResources: Set(),
                                falsePositives: Set())
    }
    
    @concurrent
    nonisolated private func fetchRecentlyViewedSupportData(newlyViewed: Set<String>) async -> BatchSupport {
        let data = await data(batchCardSupportURL(), reqBody: BatchCardRequest(cardIDs: newlyViewed),
                              resType: BatchSupport.self, httpMethod: "POST")
        if case .success(let suggestions) = data {
            return suggestions
        }
        return BatchSupport(referencedBy: [], materialFor: [], unknownResources: Set(), falsePositives: Set())
    }
    
    @concurrent
    nonisolated private func consolidateSuggestions(suggestions: BatchSuggestions, support: BatchSupport) async -> [CardReference] {
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
