//
//  TrendingViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/26/24.
//

import Foundation

class TrendingViewModel: ObservableObject {
    @Published private(set) var cards: [TrendingMetric<Card>]?
    @Published private(set) var products: [TrendingMetric<Product>]?
    private var trendingDataLastRefresh = Date()
    
    func fetchTrendingData() async {
        if cards == nil || products == nil || trendingDataLastRefresh.timeIntervalSinceNow(millisConversion: .minutes) >= 5  {
            request(url: trendingUrl(resource: .card), priority: 0.2) { (result: Result<Trending<Card>, Error>) -> Void in
                switch result {
                case .success(let trending):
                    DispatchQueue.main.async {
                        self.cards = trending.metrics
                    }
                case .failure(let error):
                    print(error)
                }
            }
            
            request(url: trendingUrl(resource: .product), priority: 0.2) { (result: Result<Trending<Product>, Error>) -> Void in
                switch result {
                case .success(let trending):
                    DispatchQueue.main.async {
                        self.products = trending.metrics
                    }
                case .failure(let error):
                    print(error)
                }
            }
            
            trendingDataLastRefresh = Date()
        }
    }
}
