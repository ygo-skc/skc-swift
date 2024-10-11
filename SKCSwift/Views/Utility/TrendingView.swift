//
//  Trending.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/22/24.
//

import SwiftUI

struct TrendingView: View, @preconcurrency Equatable {
    let cardTrendingData: [TrendingMetric<Card>]
    let productTrendingData: [TrendingMetric<Product>]
    
    @State private var focusedTrend = TrendingResourceType.card
    
    static func == (lhs: TrendingView, rhs: TrendingView) -> Bool {
        lhs.focusedTrend == rhs.focusedTrend
        && lhs.cardTrendingData.elementsEqual(rhs.cardTrendingData, by: { $0.resource.cardID == $1.resource.cardID && $0.occurrences == $1.occurrences })
        && lhs.productTrendingData.elementsEqual(rhs.productTrendingData, by: { $0.resource.productId == $1.resource.productId && $0.occurrences == $1.occurrences })
    }
    
    var body: some View {
        SectionView(header: "Trending",
                    variant: .plain,
                    content: {
            Picker("Select Trend Type", selection: $focusedTrend) {
                ForEach(TrendingResourceType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized).tag(type)
                }
            }
            .pickerStyle(.segmented)
            
            if focusedTrend == .card {
                TrendingCardsView(trendingCards: cardTrendingData)
            } else if focusedTrend == .product {
                TrendingProductsView(trendingProducts: productTrendingData)
            }
        })
    }
}

private struct TrendingCardsView: View {
    let trendingCards: [TrendingMetric<Card>]
    
    var body: some View {
        LazyVStack {
            ForEach(trendingCards, id: \.resource.cardID) { m in
                let card = m.resource
                NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
                    GroupBox(label: TrendChangeView(trendChange: m.change, hits: m.occurrences)) {
                        CardListItemView(card: card)
                            .equatable()
                    }
                    .groupBoxStyle(.listItem)
                })
                .buttonStyle(.plain)
            }
        }
    }
}

private struct TrendingProductsView: View {
    let trendingProducts: [TrendingMetric<Product>]
    
    var body: some View {
        LazyVStack {
            ForEach(trendingProducts, id: \.resource.productId) { m in
                let product = m.resource
                NavigationLink(value: ProductLinkDestinationValue(productID: product.productId, productName: product.productName), label: {
                    GroupBox(label: TrendChangeView(trendChange: m.change, hits: m.occurrences)) {
                        ProductListItemView(product: product)
                            .equatable()
                    }
                    .groupBoxStyle(.listItem)
                })
                .buttonStyle(.plain)
            }
        }
    }
}


private struct TrendChangeView: View, Equatable {
    private let trendLabel: String
    private let trendColor: Color
    private let trendImage: String
    
    init(trendChange: Int, hits: Int) {
        if trendChange > 0 {
            trendLabel = "+\(trendChange) • \(hits) hits"
            trendColor = .mint
            trendImage = "chart.line.uptrend.xyaxis"
        } else if trendChange < 0 {
            trendLabel = "\(trendChange) • \(hits) hits"
            trendColor = .dateRed
            trendImage = "chart.line.downtrend.xyaxis"
        } else {
            trendLabel = "±\(trendChange) • \(hits) hits"
            trendColor = .normalYGOCard
            trendImage = "chart.line.flattrend.xyaxis"
        }
    }
    
    var body: some View {
        Label {
            Text(trendLabel)
                .foregroundColor(.secondary)
        } icon: {
            Image(systemName: trendImage)
                .foregroundColor(trendColor)
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
