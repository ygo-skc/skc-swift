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
        if cards == nil || trendingCardDataLastFetch.timeIntervalSinceNow(millisConversion: .minutes) >= 5,
            let trending = try? await data(Trending<Card>.self, url: trendingUrl(resource: .card)) {
            DispatchQueue.main.async {
                self.cards = trending.metrics
            }
        }
        trendingCardDataLastFetch = Date()
    }
    
    func fetchTrendingProducts() async {
        if products == nil || trendingProductDataLastFetch.timeIntervalSinceNow(millisConversion: .minutes) >= 5,
            let trending: Trending<Product> = try? await data(Trending<Product>.self, url: trendingUrl(resource: .product)) {
            DispatchQueue.main.async {
                self.products = trending.metrics
            }
        }
        trendingProductDataLastFetch = Date()
    }
}
