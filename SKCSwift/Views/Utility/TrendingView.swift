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
            ScrollView {
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
            .scrollDisabled(model.trendingRequestErrors[model.focusedTrend] != nil)
        }
        .overlay {
            if !Set([.uninitiated, .pending]).isDisjoint(with: Set(model.trendingDataTaskStatuses.values)) {
                ProgressView("Loading...")
                    .controlSize(.large)
            }
            
            switch model.focusedTrend {
            case .card:
                if let networkError = model.trendingRequestErrors[model.focusedTrend, default: nil] {
                    NetworkErrorView(error: networkError, action: {
                        Task {
                            await model.fetchTrendingCards(forceRefresh: true)
                        }
                    })
                }
            case .product:
                if let networkError = model.trendingRequestErrors[model.focusedTrend, default: nil] {
                    NetworkErrorView(error: networkError, action: {
                        Task {
                            await model.fetchTrendingProducts(forceRefresh: true)
                        }
                    })
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
    var trendingCards: [TrendingMetric<Card>]
    
    var body: some View {
        VStack {
            ForEach(Array(trendingCards.enumerated()), id: \.element.resource.cardID) {position, m in
                let card = m.resource
                NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
                    GroupBox(label: TrendChangeView(position: position + 1, trendChange: m.change, hits: m.occurrences)) {
                        CardListItemView(card: card)
                            .equatable()
                    }
                    .groupBoxStyle(.listItem)
                })
                .dynamicTypeSize(...DynamicTypeSize.medium)
                .buttonStyle(.plain)
            }
        }
    }
}

private struct TrendingProductsView: View {
    let trendingProducts: [TrendingMetric<Product>]
    
    var body: some View {
        VStack {
            ForEach(Array(trendingProducts.enumerated()), id: \.element.resource.productId) { position, m in
                let product = m.resource
                NavigationLink(value: ProductLinkDestinationValue(productID: product.productId, productName: product.productName), label: {
                    GroupBox(label: TrendChangeView(position: position + 1, trendChange: m.change, hits: m.occurrences)) {
                        ProductListItemView(product: product)
                            .equatable()
                    }
                    .dynamicTypeSize(...DynamicTypeSize.medium)
                    .groupBoxStyle(.listItem)
                })
                .buttonStyle(.plain)
            }
        }
    }
}


private struct TrendChangeView: View, Equatable {
    private let position: Int
    private let trendLabel: String
    private let trendColor: Color
    private let trendImage: String
    
    init(position: Int, trendChange: Int, hits: Int) {
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
        self.position = position
    }
    
    var body: some View {
        HStack {
            Label {
                Text(trendLabel)
                    .foregroundColor(.secondary)
            } icon: {
                Image(systemName: trendImage)
                    .foregroundColor(trendColor)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            Text("#\(position)")
                .font(.headline)
                .foregroundStyle(.secondary )
        }
    }
}

#Preview {
    TrendingView(model: TrendingViewModel())
}

#Preview("Trend Change Positive") {
    TrendChangeView(position: 1, trendChange: 1, hits: 1040)
}

#Preview("Trend Change Negative") {
    TrendChangeView(position: 2, trendChange: -1, hits: 100203)
}

#Preview("Trend Change Neutral") {
    TrendChangeView(position: 4, trendChange: 0, hits: 10)
}
