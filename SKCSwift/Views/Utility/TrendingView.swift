//
//  Trending.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/22/24.
//

import SwiftUI

struct TrendingView: View, Equatable {
    let cardTrendingData: [TrendingMetric<Card>]
    let productTrendingData: [TrendingMetric<Product>]
    
    @State private var focusedTrend = TrendingResouceType.card
    
    static func == (lhs: TrendingView, rhs: TrendingView) -> Bool {
        lhs.focusedTrend == rhs.focusedTrend
        && lhs.cardTrendingData.elementsEqual(rhs.cardTrendingData, by: { $0.resource.cardID == $1.resource.cardID })
        && lhs.productTrendingData.elementsEqual(rhs.productTrendingData, by: { $0.resource.productId == $1.resource.productId })
    }
    
    var body: some View {
        SectionView(header: "Trending",
                    variant: .plain,
                    content: {
            Picker("Select Trend Type", selection: $focusedTrend) {
                ForEach(TrendingResouceType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized).tag(type)
                }
            }
            .pickerStyle(.segmented)
            
            LazyVStack{
                if focusedTrend == .card {
                    ForEach(cardTrendingData, id: \.resource.cardID) { m in
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
                } else if focusedTrend == .product {
                    ForEach(productTrendingData, id: \.resource.productId) { m in
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
        })
    }
}


private struct TrendChangeView: View, Equatable {
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
    TrendingView(cardTrendingData: [
        TrendingMetric(resource: Card(cardID: "40044918", cardName: "Elemental HERO Stratos", cardColor: "Effect",
                                      cardAttribute: "Wind", cardEffect: "Draw 2", monsterType: "Warrior/Effect"), occurrences: 45, change: 3)],
                 productTrendingData: [
                    TrendingMetric(resource: Product(productId: "PHNI", productLocale: "EN", productName: "Phantom Nightmare",
                                                     productType: "Pack", productSubType: "Core Set", productReleaseDate: "2024-03-03", productTotal: 101), occurrences: 23, change: -4)])
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
