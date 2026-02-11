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
    
    var trendingProducts: some View {
        VStack {
            ForEach(Array(trendingModel.products.enumerated()), id: \.element.resource.productId) { position, m in
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
    
    var body: some View {
        ScrollView {
            VStack {
                Picker("Select Trend Type", selection: $trendingModel.focusedTrend) {
                    ForEach(TrendingResourceType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
                if [.done, .pending].contains(trendingModel.focusedTrendDTS) {
                    switch trendingModel.focusedTrend {
                    case .card:
                        CardListView(cards: trendingModel.cards.map({ $0.resource }), label: { ind in
                            TrendChangeView(position: ind + 1,
                                            trendChange: trendingModel.cards[ind].change,
                                            hits: trendingModel.cards[ind].occurrences)
                        })
                    case .product:
                        trendingProducts
                    }
                }
            }
            .modifier(.parentView)
        }
        .task {
            await trendingModel.fetchTrendingData(forceRefresh: false)
        }
        .dynamicTypeSize(...DynamicTypeSize.medium)
        .scrollDisabled(trendingModel.focusedTrendNE != nil)
        .frame(maxWidth: .infinity)
        .overlay {
            if trendingModel.focusedTrendDTS == .error, let networkError = trendingModel.focusedTrendNE {
                NetworkErrorView(error: networkError, action: {
                    Task {
                        await trendingModel.fetchTrendingData(forceRefresh: true)
                    }
                })
            } else if DataTaskStatusParser.isDataPending(trendingModel.focusedTrendDTS) {
                ProgressView("Loading...")
                    .controlSize(.large)
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
        HStack(spacing: 8) {
            Label {
                Text(trendLabel)
            } icon: {
                Image(systemName: trendImage)
            }
            .foregroundColor(trendColor)
            
            Divider()
            
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
        .frame(height: 20)
        .padding(.horizontal)
}

#Preview("Trend Change Negative") {
    TrendChangeView(position: 2, trendChange: -1, hits: 100203)
        .frame(height: 20)
        .padding(.horizontal)
}

#Preview("Trend Change Neutral") {
    TrendChangeView(position: 4, trendChange: 0, hits: 10)
        .frame(height: 20)
        .padding(.horizontal)
}
