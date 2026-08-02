//
//  TrendingViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/26/24.
//

import Foundation

@Observable
final class TrendingViewModel {
    var focusedTrend = TrendingResourceType.card
    
    @ObservationIgnored
    private(set) var cards: [TrendingMetric<YGOCard>] = []
    @ObservationIgnored
    private(set) var products: [TrendingMetric<Product>] = []
    
    private(set) var trendingCardsDTS: DataTaskStatus = .pending
    private(set) var trendingProductsDTS: DataTaskStatus = .pending
    
    @ObservationIgnored
    private(set) var trendingCardsNE: NetworkError? = nil
    @ObservationIgnored
    private(set) var trendingProductsNE: NetworkError? = nil
    
    @ObservationIgnored
    var focusedTrendDTS: DataTaskStatus {
        return (focusedTrend == .card) ? trendingCardsDTS : trendingProductsDTS
    }
    @ObservationIgnored
    var focusedTrendNE: NetworkError? {
        return (focusedTrend == .card) ? trendingCardsNE : trendingProductsNE
    }
    
    @ObservationIgnored
    private var lastRefreshTimestamp = Date.distantPast

    func fetchTrendingData(forceRefresh: Bool = false) async {
        guard forceRefresh || trendingCardsNE != nil || trendingProductsNE != nil
                || lastRefreshTimestamp.isDateInvalidated(5) else { return }
        await withTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask { @Sendable in await self.fetchTrendingCards() }
            taskGroup.addTask { @Sendable in await self.fetchTrendingProducts() }
        }
        lastRefreshTimestamp = Date()
    }

    private func fetchTrendingCards() async {
        (trendingCardsNE, trendingCardsDTS) = (nil, .pending)
        (trendingCardsNE, trendingCardsDTS) = await data(trendingUrl(resource: .card), resType: Trending<YGOCard>.self)
            .validate(&cards, keyPath: \.metrics)
    }
    
    private func fetchTrendingProducts() async {
        (trendingProductsNE, trendingProductsDTS) = (nil, .pending)
        (trendingProductsNE, trendingProductsDTS) = await data(trendingUrl(resource: .product), resType: Trending<Product>.self)
            .validate(&products, keyPath: \.metrics)
    }
}
