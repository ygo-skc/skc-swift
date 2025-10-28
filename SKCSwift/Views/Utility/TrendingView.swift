//
//  Trending.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/22/24.
//

import SwiftUI

struct TrendingView: View {
    @Binding var path: NavigationPath
    @Binding var trendingModel: TrendingViewModel
    
    var body: some View {
        ScrollView {
            SectionView(header: "Trending",
                        variant: .plain,
                        content: {
                Picker("Select Trend Type", selection: $trendingModel.focusedTrend) {
                    ForEach(TrendingResourceType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
                
                if trendingModel.trendingRequestErrors[trendingModel.focusedTrend, default: nil] == nil  {
                    switch trendingModel.focusedTrend {
                    case .card:
                        TrendingCardsView(path: $path, trendingCards: trendingModel.cards)
                    case .product:
                        TrendingProductsView(path: $path, trendingProducts: trendingModel.products)
                    }
                }
            })
            .modifier(.parentView)
            .task {
                await trendingModel.fetchTrendingData(forceRefresh: false)
            }
            .dynamicTypeSize(...DynamicTypeSize.medium)
        }
        .scrollDisabled(trendingModel.trendingRequestErrors[trendingModel.focusedTrend] != nil)
        .frame(maxWidth: .infinity)
        .overlay {
            if let networkError = trendingModel.trendingRequestErrors[trendingModel.focusedTrend, default: nil] {
                NetworkErrorView(error: networkError, action: {
                    Task {
                        await trendingModel.fetchTrendingData(forceRefresh: true)
                    }
                })
            } else if DataTaskStatusParser.isDataPending(trendingModel.trendingDataTaskStatuses[trendingModel.focusedTrend]!) {
                ProgressView("Loading...")
                    .controlSize(.large)
            }
        }
    }
}

private struct TrendingCardsView: View {
    @Binding var path: NavigationPath
    let trendingCards: [TrendingMetric<Card>]
    
    var body: some View {
        VStack {
            ForEach(Array(trendingCards.enumerated()), id: \.element.resource.cardID) { position, m in
                let card = m.resource
                Button {
                    path.append(CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName))
                } label: {
                    GroupBox(label: TrendChangeView(position: position + 1, trendChange: m.change, hits: m.occurrences)) {
                        CardListItemView(card: card)
                            .equatable()
                    }
                    .groupBoxStyle(.listItem)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct TrendingProductsView: View {
    @Binding var path: NavigationPath
    let trendingProducts: [TrendingMetric<Product>]
    
    var body: some View {
        VStack {
            ForEach(Array(trendingProducts.enumerated()), id: \.element.resource.productId) { position, m in
                let product = m.resource
                Button {
                    path.append(ProductLinkDestinationValue(productID: product.productId, productName: product.productName))
                } label: {
                    GroupBox(label: TrendChangeView(position: position + 1, trendChange: m.change, hits: m.occurrences)) {
                        ProductListItemView(product: product)
                            .equatable()
                    }
                    .groupBoxStyle(.listItem)
                }
                .buttonStyle(.plain)
            }
        }
    }
}


private struct TrendChangeView: View, Equatable {
    private let position: Int
    private let hits: Int
    private let trendLabel: String
    private let trendColor: Color
    private let trendImage: String
    
    init(position: Int, trendChange: Int, hits: Int) {
        if trendChange > 0 {
            trendLabel = "+\(trendChange)"
            trendColor = .mint
            trendImage = "chart.line.uptrend.xyaxis"
        } else if trendChange < 0 {
            trendLabel = "\(trendChange)"
            trendColor = .dateRed
            trendImage = "chart.line.downtrend.xyaxis"
        } else {
            trendLabel = "±\(trendChange)"
            trendColor = .orange
            trendImage = "chart.line.flattrend.xyaxis"
        }
        self.position = position
        self.hits = hits
    }
    
    var body: some View {
        HStack {
            Label {
                Text(trendLabel)
            } icon: {
                Image(systemName: trendImage)
            }
            .foregroundColor(trendColor)
            
            Label {
                Text(String(hits))
            } icon: {
                Image(systemName: "chart.bar.xaxis")
            }
            .foregroundColor(.secondary)
            
            Spacer()
            
            Text("#\(position)")
                .font(.headline)
                .fontWeight(.thin)
        }
    }
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
