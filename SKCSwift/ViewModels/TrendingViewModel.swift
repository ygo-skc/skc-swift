//
//  TrendingViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/26/24.
//

import Foundation

@Observable
class TrendingViewModel {
    private static let invalidateDataThreshold = 5
    
    var focusedTrend = TrendingResourceType.card
    
    private(set) var cards: [TrendingMetric<Card>] = []
    private(set) var products: [TrendingMetric<Product>] = []
    
    private(set) var trendingCardError: NetworkError? = nil
    private(set) var trendingProductError: NetworkError? = nil
    
    @ObservationIgnored
    private var trendingCardDataLastFetch = Date.distantPast
    @ObservationIgnored
    private var trendingProductDataLastFetch = Date.distantPast
    
    @MainActor
    func fetchTrendingCards() async {
        if trendingCardDataLastFetch.isDateInvalidated(TrendingViewModel.invalidateDataThreshold) {
            switch await data(Trending<Card>.self, url: trendingUrl(resource: .card)) {
            case .success(let trending):
                cards = trending.metrics
                trendingCardDataLastFetch = Date()
            case .failure(let error):
                trendingCardError = error
            }
        }
    }
    
    @MainActor
    func fetchTrendingProducts() async {
        if trendingProductDataLastFetch.isDateInvalidated(TrendingViewModel.invalidateDataThreshold) {
            switch await data(Trending<Product>.self, url: trendingUrl(resource: .product)) {
            case .success(let trending):
                products = trending.metrics
                trendingProductDataLastFetch = Date()
            case .failure(let error):
                trendingProductError = error
            }
        }
    }
}
