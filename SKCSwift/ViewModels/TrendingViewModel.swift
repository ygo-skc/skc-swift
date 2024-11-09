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
    
    // init values with .uninitiated so progress view can be displayed
    private(set) var trendingDataTaskStatuses: [TrendingResourceType: DataTaskStatus] = Dictionary(uniqueKeysWithValues: TrendingResourceType.allCases.map { ($0, .uninitiated) })
    private(set) var trendingRequestErrors: [TrendingResourceType: NetworkError?] = [:]
    
    @ObservationIgnored
    private var trendingDataLastFetched: [TrendingResourceType: Date] = [:]
    
    private static let invalidateDataThreshold = 5
    
    @MainActor
    func fetchTrendingCards(forceRefresh: Bool = false) async {
        await fetchTrendingData(forceRefresh: forceRefresh, resource: .card) {
            await data(Trending<Card>.self, url: trendingUrl(resource: .card))
        }
    }
    
    @MainActor
    func fetchTrendingProducts(forceRefresh: Bool = false) async {
        await fetchTrendingData(forceRefresh: forceRefresh, resource: .product) {
            await data(Trending<Product>.self, url: trendingUrl(resource: .product))
        }
    }
    
    @MainActor
    private func fetchTrendingData<T: Codable>(forceRefresh: Bool, resource: TrendingResourceType, dataFetcher: @escaping @MainActor () async -> Result<Trending<T>, NetworkError>) async {
        if forceRefresh || trendingDataLastFetched[.product, default: .distantPast].isDateInvalidated(TrendingViewModel.invalidateDataThreshold) {
            trendingDataTaskStatuses[resource] = .pending
            switch await dataFetcher() {
            case .success(let trending):
                if let products = trending.metrics as? [TrendingMetric<Product>] {
                    self.products = products
                } else if let cards = trending.metrics as? [TrendingMetric<Card>] {
                    self.cards = cards
                }
                
                trendingDataLastFetched[resource] = Date()
                trendingRequestErrors[resource] = nil
            case .failure(let error):
                trendingRequestErrors[resource] = error
            }
            trendingDataTaskStatuses[resource] = .done
        }
    }
}
