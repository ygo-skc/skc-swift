//
//  Trending.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/22/24.
//

import SwiftUI

struct TrendingView: View {
    @Bindable var model: TrendingViewModel
    
    var body: some View {
        VStack {
            if let trendingCardError = model.trendingCardError, let trendingProductError = model.trendingProductError {
                
            } else if model.cards.isEmpty || model.products.isEmpty {
                ProgressView("Loading...")
                    .controlSize(.large)
            } else {
                ScrollView() {
                    SectionView(header: "Trending",
                                variant: .plain,
                                content: {
                        Picker("Select Trend Type", selection: $model.focusedTrend) {
                            ForEach(TrendingResourceType.allCases, id: \.self) { type in
                                Text(type.rawValue.capitalized).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        
                        switch model.focusedTrend {
                        case .card:
                            TrendingCardsView(trendingCards: model.cards)
                        case .product:
                            TrendingProductsView(trendingProducts: model.products)
                        }
                    })
                    .modifier(ParentViewModifier())
                }
            }
        }
        .task(priority: .userInitiated) {
            await model.fetchTrendingCards()
        }
        .task(priority: .medium) {
            await model.fetchTrendingProducts()
        }
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
    TrendingView(model: TrendingViewModel())
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
