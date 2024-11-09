//
//  TrendingViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/26/24.
//

import Foundation

@Observable
class TrendingViewModel {
    private static let invalidateDataThreshold = 1
    
    var focusedTrend = TrendingResourceType.card
    
    private(set) var cards: [TrendingMetric<Card>] = []
    private(set) var products: [TrendingMetric<Product>] = []
    
    private(set) var trendingCardTask = DataTaskStatus.uninitiated
    private(set) var trendingProductTask = DataTaskStatus.uninitiated
    
    @ObservationIgnored
    private var trendingCardDataLastFetch = Date.distantPast
    @ObservationIgnored
    private var trendingProductDataLastFetch = Date.distantPast
    
    @MainActor
    func fetchTrendingCards() async {
        if trendingCardDataLastFetch.isDateInvalidated(TrendingViewModel.invalidateDataThreshold) {
            trendingCardTask = .pending
            switch await data(Trending<Card>.self, url: trendingUrl(resource: .card)) {
            case .success(let trending):
                cards = trending.metrics
                trendingCardDataLastFetch = Date()
                trendingCardTask = .done
            case .failure(let error):
                trendingCardTask = determineTaskState(error: error)
            }
        }
    }
    
    @MainActor
    func fetchTrendingProducts() async {
        if trendingProductDataLastFetch.isDateInvalidated(TrendingViewModel.invalidateDataThreshold) {
            trendingProductTask = .pending
            switch await data(Trending<Product>.self, url: trendingUrl(resource: .product)) {
            case .success(let trending):
                products = trending.metrics
                trendingProductDataLastFetch = Date()
                trendingProductTask = .done
            case .failure(let error):
                trendingProductTask = determineTaskState(error: error)
            }
        }
    }
    
    private func determineTaskState(error: NetworkError) -> DataTaskStatus {
        switch error {
        case .timeout, .cancelled:
            return .timeout
        default:
            return .error
        }
    }
}
