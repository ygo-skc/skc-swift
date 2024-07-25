//
//  Trending.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/22/24.
//

import SwiftUI

struct TrendingView: View {
    @State private var cardTrendingData: [TrendingMetric<Card>]?
    @State private var productTrendingData: [TrendingMetric<Product>]?
    @State private var focusedTrend: TrendingResouceType = .card
    @State private var isDataLoaded = false
    @State private var lastRefresh = Date()
    
    private func fetchData() {
        if isDataLoaded{
            if lastRefresh.timeIntervalSinceNow(millisConversion: .minutes) < 5 {
                return
            }
        }
        
        request(url: trendingUrl(resource: .card), priority: 0.2) { (result: Result<Trending<Card>, Error>) -> Void in
            DispatchQueue.main.async {
                switch result {
                case .success(let trending):
                    cardTrendingData = trending.metrics
                    isDataLoaded = true
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        request(url: trendingUrl(resource: .product), priority: 0.2) { (result: Result<Trending<Product>, Error>) -> Void in
            DispatchQueue.main.async {
                switch result {
                case .success(let trending):
                    productTrendingData = trending.metrics
                    isDataLoaded = true
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    var body: some View {
        ScrollView(content: {
            SectionView(header: "Trending",
                        variant: .plain,
                        content: {
                if isDataLoaded {
                    LazyVStack{
                        Picker("Select Trend Type", selection: $focusedTrend) {
                            ForEach(TrendingResouceType.allCases, id: \.self) { type in
                                Text(type.rawValue.capitalized).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.bottom)
                        
                        if focusedTrend == .card, let tm = cardTrendingData {
                            ForEach(tm, id: \.resource.cardID) { m in
                                let card = m.resource
                                NavigationLink(value: CardValue(cardID: card.cardID, cardName: card.cardName), label: {
                                    HStack {
                                        TrendChangeView(trendChange: m.change, hits: m.occurrences)
                                        VStack {
                                            CardListItemView(cardID: card.cardID, cardName: card.cardName, monsterType: card.monsterType)
                                            Divider()
                                        }
                                        .padding(.leading, 5)
                                    }
                                    .contentShape(Rectangle())
                                })
                                .buttonStyle(.plain)
                            }
                        } else if focusedTrend == .product, let tm = productTrendingData {
                            ForEach(tm, id: \.resource.productId) { m in
                                let product = m.resource
                                HStack {
                                    TrendChangeView(trendChange: m.change, hits: m.occurrences)
                                    VStack {
                                        ProductListItemView(product: product)
                                        Divider()
                                    }
                                    .padding(.leading, 5)
                                }
                            }
                        }
                    }
                } else {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            })
            .padding(.horizontal)
        })
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .scrollDismissesKeyboard(.immediately)
        .task(priority: .low) {
            fetchData()
        }
    }
}


private struct TrendChangeView: View {
    let trendChange: String
    let hits: Int
    
    private let trendColor: Color
    private let trendImage: String
    
    init(trendChange: Int, hits: Int) {
        self.hits = hits
        
        if trendChange > 0 {
            self.trendChange = "+\(trendChange)".padding(toLength: 3, withPad: " ", startingAt: 0)
            trendColor = .mint
            trendImage = "chart.line.uptrend.xyaxis"
        } else if trendChange < 0 {
            self.trendChange = "\(trendChange)".padding(toLength: 3, withPad: " ", startingAt: 0)
            trendColor = .pinkRed
            trendImage = "chart.line.downtrend.xyaxis"
        } else {
            self.trendChange = "±\(trendChange)".padding(toLength: 3, withPad: " ", startingAt: 0)
            trendColor = .normalYgoCard
            trendImage = "chart.line.flattrend.xyaxis"
        }
    }
    
    
    var body: some View {
        VStack {
            HStack(spacing: 0.5) {
                Image(systemName: trendImage)
                    .foregroundColor(trendColor)
                    .font(.title)
                    .fontWeight(.medium)
                Text(trendChange)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
                    .font(.system(.title3, design: .monospaced))
            }
            Text("\(hits) Hits")
                .foregroundColor(.secondary)
                .font(.footnote)
        }
    }
}

#Preview {
    TrendingView()
}

#Preview("Trend Change Positive") {
    TrendChangeView(trendChange: 1, hits: 1040)
}

#Preview("Trend Change Negative") {
    TrendChangeView(trendChange: -1, hits: 100203)
}

#Preview("Trend Change Neutral") {
    TrendChangeView(trendChange: 0, hits: 10)
}