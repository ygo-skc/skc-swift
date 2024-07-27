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
        self.trendingDataLastRefresh = Date()
        
        request(url: trendingUrl(resource: .card), priority: 0.2) { (result: Result<Trending<Card>, Error>) -> Void in
            switch result {
            case .success(let trending):
                DispatchQueue.main.async {
                    self.cards = trending.metrics
                    self.isDataLoaded = true
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
                    self.isDataLoaded = true
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
