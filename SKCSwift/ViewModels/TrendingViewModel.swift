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
    private(set) var cards: [TrendingMetric<Card>] = []
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
    private var trendingDataLastFetched: [TrendingResourceType: Date] = [:]
    
    @ObservationIgnored
    private static let invalidateDataThreshold = 5
    
    func fetchTrendingData(forceRefresh: Bool = false) async {
        await withTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask { @Sendable in await self.fetchTrendingCards(forceRefresh: forceRefresh) }
            taskGroup.addTask { @Sendable in await self.fetchTrendingProducts(forceRefresh: forceRefresh) }
        }
    }
    
    private func fetchTrendingCards(forceRefresh: Bool = false) async {
        trendingCardsDTS = .pending
        let res = await data(trendingUrl(resource: .card), resType: Trending<Card>.self)
        cards = (try? res.get().metrics) ?? cards
        (trendingCardsNE, trendingCardsDTS) = res.validate()
    }
    
    private func fetchTrendingProducts(forceRefresh: Bool = false) async {
        trendingProductsDTS = .pending
        let res = await data(trendingUrl(resource: .product), resType: Trending<Product>.self)
        products = (try? res.get().metrics) ?? products
        (trendingProductsNE, trendingProductsDTS) = res.validate()
    }
}
