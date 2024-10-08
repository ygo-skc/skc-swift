//
//  TrendingViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/26/24.
//

import Foundation

@Observable
class TrendingViewModel {
    private(set) var cards: [TrendingMetric<Card>]?
    private(set) var products: [TrendingMetric<Product>]?
    
    @ObservationIgnored
    private var trendingCardDataLastFetch = Date()
    @ObservationIgnored
    private var trendingProductDataLastFetch = Date()
    
    func fetchTrendingCards() async {
        if cards == nil || trendingCardDataLastFetch.isDateInvalidated(5) {
            switch await data(Trending<Card>.self, url: trendingUrl(resource: .card)) {
            case .success(let trending):
                Task { @MainActor in
                    self.cards = trending.metrics
                }
            case .failure(_): break
            }
            trendingCardDataLastFetch = Date()
        }
    }
    
    func fetchTrendingProducts() async {
        if products == nil || trendingProductDataLastFetch.isDateInvalidated(5) {
            switch await data(Trending<Product>.self, url: trendingUrl(resource: .product)) {
            case .success(let trending):
                Task { @MainActor in
                    self.products = trending.metrics
                }
            case .failure(_): break
            }
            trendingProductDataLastFetch = Date()
        }
    }
}
