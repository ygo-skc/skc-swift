//
//  TrendingViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/26/24.
//

import Foundation

@Observable
class TrendingViewModel {
    var focusedTrend = TrendingResourceType.card
    
    private(set) var cards: [TrendingMetric<Card>] = []
    private(set) var products: [TrendingMetric<Product>] = []
    
    private(set) var trendingCardStatus = DataTaskStatus.uninitiated
    private(set) var trendingProductStatus = DataTaskStatus.uninitiated
    
    private(set) var trendingCardError: NetworkError? = nil
    private(set) var trendingProductError: NetworkError? = nil
    
    @ObservationIgnored
    private var trendingCardDataLastFetch = Date.distantPast
    @ObservationIgnored
    private var trendingProductDataLastFetch = Date.distantPast
    
    private static let invalidateDataThreshold = 5
    
    @MainActor
    func fetchTrendingCards(forceRefresh: Bool = false) async {
        if forceRefresh || trendingCardDataLastFetch.isDateInvalidated(TrendingViewModel.invalidateDataThreshold) {
            trendingCardStatus = .pending
            switch await data(Trending<Card>.self, url: trendingUrl(resource: .card)) {
            case .success(let trending):
                cards = trending.metrics
                trendingCardDataLastFetch = Date()
                trendingCardError = nil
            case .failure(let error):
                trendingCardError = error
            }
            trendingCardStatus = .done
        }
    }
    
    @MainActor
    func fetchTrendingProducts(forceRefresh: Bool = false) async {
        if forceRefresh || trendingProductDataLastFetch.isDateInvalidated(TrendingViewModel.invalidateDataThreshold) {
            trendingProductStatus = .pending
            switch await data(Trending<Product>.self, url: trendingUrl(resource: .product)) {
            case .success(let trending):
                products = trending.metrics
                trendingProductDataLastFetch = Date()
                trendingProductError = nil
            case .failure(let error):
                trendingProductError = error
            }
            trendingProductStatus = .done
        }
    }
}
