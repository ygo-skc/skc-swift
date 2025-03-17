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
    @ObservationIgnored
    private var recentlyViewedCardInfo = [String: Card]()
    
    func fetchRecentlyViewedDetails(recentlyViewed newHistory: [History]) async {
        let recentlyViewedCardIDs = Set(newHistory.map { $0.id })
        
        requestError = nil
        dataTaskStatus = .pending
        (recentlyViewedCardInfo, requestError) = await fetchRecentlyViewedDetails(newRecentlyViewed: recentlyViewedCardIDs,
                                                                                                    recentlyViewedCardInfo: recentlyViewedCardInfo)
        recentlyViewedCardDetails = newHistory.map{ recentlyViewedCardInfo[$0.id] }.compactMap{ $0 }
        dataTaskStatus = .done
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
