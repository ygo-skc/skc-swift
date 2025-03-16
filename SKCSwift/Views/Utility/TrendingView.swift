//
//  Trending.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/22/24.
//

import SwiftUI

struct TrendingView: View, Equatable {
    nonisolated static func == (lhs: TrendingView, rhs: TrendingView) -> Bool {
        MainActor.assumeIsolated {
            return lhs.focusedTrend == rhs.focusedTrend && lhs.cards == rhs.cards && lhs.products == rhs.products
            && lhs.trendingDataTaskStatuses == rhs.trendingDataTaskStatuses && lhs.trendingRequestErrors == rhs.trendingRequestErrors
        }
    }
    
    @Binding var path: NavigationPath
    @Binding var focusedTrend: TrendingResourceType
    let cards: [TrendingMetric<Card>]
    let products: [TrendingMetric<Product>]
    let trendingDataTaskStatuses: [TrendingResourceType: DataTaskStatus]
    let trendingRequestErrors: [TrendingResourceType: NetworkError?]
    let fetchTrendingData: (Bool) async -> Void
    
    var body: some View {
        ScrollView {
            SectionView(header: "Trending",
                        variant: .plain,
                        content: {
                Picker("Select Trend Type", selection: $focusedTrend) {
                    ForEach(TrendingResourceType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
                
                if trendingRequestErrors[focusedTrend, default: nil] == nil  {
                    switch focusedTrend {
                    case .card:
                        TrendingCardsView(path: $path, trendingCards: cards)
                    case .product:
                        TrendingProductsView(path: $path, trendingProducts: products)
                    }
                }
            })
            .modifier(.parentView)
        }
        .dynamicTypeSize(...DynamicTypeSize.medium)
        .scrollDisabled(trendingRequestErrors[focusedTrend] != nil)
        .overlay {
            if let networkError = trendingRequestErrors[focusedTrend, default: nil] {
                NetworkErrorView(error: networkError, action: {
                    Task {
                        await fetchTrendingData(true)
                    }
                })
            } else if [DataTaskStatus.uninitiated, DataTaskStatus.pending].contains(trendingDataTaskStatuses[focusedTrend])  {
                ProgressView("Loading...")
                    .controlSize(.large)
            }
        }
        .task {
            await fetchTrendingData(false)
        }
    }
}

private struct TrendingCardsView: View {
    @Binding var path: NavigationPath
    let trendingCards: [TrendingMetric<Card>]
    
    var body: some View {
        VStack {
            ForEach(Array(trendingCards.enumerated()), id: \.element.resource.cardID) {position, m in
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
