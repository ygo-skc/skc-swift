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
    @Published private(set) var isDataLoaded = false
    @Published var focusedTrend: TrendingResouceType = .card
    private var trendingDataLastRefresh = Date()
    
    func fetchTrendingData() {
        if isDataLoaded {
            if trendingDataLastRefresh.timeIntervalSinceNow(millisConversion: .minutes) < 5 {
                return
            }
        }
        
        request(url: trendingUrl(resource: .card), priority: 0.2) { (result: Result<Trending<Card>, Error>) -> Void in
            DispatchQueue.main.async {
                switch result {
                case .success(let trending):
                    self.cards = trending.metrics
                    self.isDataLoaded = true
                    self.trendingDataLastRefresh = Date()
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        request(url: trendingUrl(resource: .product), priority: 0.2) { (result: Result<Trending<Product>, Error>) -> Void in
            DispatchQueue.main.async {
                switch result {
                case .success(let trending):
                    self.products = trending.metrics
                    self.isDataLoaded = true
                    self.trendingDataLastRefresh = Date()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
