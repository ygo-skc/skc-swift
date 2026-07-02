//
//  TrendingView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct TrendingView: View {
    @State private var path = NavigationPath()
    @State private var trendingModel =  TrendingViewModel()
    
    @ViewBuilder
    var trendingProducts: some View {
        VStack {
            ForEach(trendingModel.products.indices, id: \.self) { index in
                let m = trendingModel.products[index]
                let product = m.resource
                Button {
                    path.append(ProductLinkDestinationValue(productID: product.productId, productName: product.productName))
                } label: {
                    GroupBox(label: TrendChangeView(position: index + 1, trendChange: m.change, hits: m.occurrences)) {
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
        NavigationStack(path: $path) {
            ScrollView {
                VStack {
                    Picker("Select Trend Type", selection: $trendingModel.focusedTrend) {
                        ForEach(TrendingResourceType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if [.done, .pending].contains(trendingModel.focusedTrendDTS) {
                        switch trendingModel.focusedTrend {
                        case .card:
                            let metrics = trendingModel.cards
                            CardListView(cards: metrics.map(\.resource), label: { ind in
                                TrendChangeView(position: ind + 1,
                                                trendChange: metrics[ind].change,
                                                hits: metrics[ind].occurrences)
                            })
                            .transition(.opacity)
                        case .product:
                            trendingProducts
                                .transition(.opacity)
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: trendingModel.focusedTrend)
                .modifier(.parentView)
            }
            .task {
                await trendingModel.fetchTrendingData(forceRefresh: false)
            }
            .ygoNavigationDestination()
            .navigationTitle("Trending")
            .navigationBarTitleDisplayMode(.large)
            .dynamicTypeSize(...DynamicTypeSize.medium)
            .scrollDisabled(trendingModel.focusedTrendNE != nil)
            .frame(maxWidth: .infinity) // needed by overlay
            .overlay {
                if trendingModel.focusedTrendDTS == .error, let networkError = trendingModel.focusedTrendNE {
                    NetworkErrorView(error: networkError, action: {
                        Task {
                            await trendingModel.fetchTrendingData(forceRefresh: true)
                        }
                    })
                } else if DataTaskStatusParser.isDataPending(trendingModel.focusedTrendDTS) {
                    ProgressView("Loading…")
                        .controlSize(.large)
                }
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
    
    private var rankColor: Color {
        switch position {
        case 1: .yellow
        case 2: Color(white: 0.6)
        case 3: .orange
        default: .primary
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Label {
                Text(trendLabel)
            } icon: {
                Image(systemName: trendImage)
            }
            .foregroundStyle(trendColor)
            
            Divider()
            
            Label {
                Text(hits.formatted())
                    .contentTransition(.numericText())
            } icon: {
                Image(systemName: "chart.bar.xaxis")
            }
            .foregroundStyle(.secondary)

            Spacer()

            Text("#\(position)")
                .font(.headline)
                .fontWeight(position <= 3 ? .semibold : .thin)
                .foregroundStyle(rankColor)
                .contentTransition(.numericText())
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

#Preview("Trending View") {
    TrendingView()
}
