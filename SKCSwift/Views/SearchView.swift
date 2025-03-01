//
//  SearchView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var searchModel = SearchViewModel()
    @State private var trendingModel = TrendingViewModel()
    
    @Query private var history: [History]
    
    init() {
        let c = ArchiveResource.card.rawValue
        _history = Query(filter: #Predicate<History> { h in
            h.resource == c
        }, sort: \History.lastAccessDate, order: .reverse)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                switch (searchModel.dataTaskStatus[.search, default: .uninitiated], searchModel.requestErrors[.search, default: nil]) {
                case (.done, _) where searchModel.searchText.isEmpty,
                    (.pending, _) where searchModel.searchText.isEmpty,
                    (.uninitiated, _):
                    if searchModel.isSearching {
                        RecentlyViewedView(recentCards: searchModel.recentlyViewedCardDetails,
                                           hasHistory: !history.isEmpty,
                                           taskStatus: searchModel.dataTaskStatus[.recentlyViewed, default: .uninitiated],
                                           requestError: searchModel.requestErrors[.recentlyViewed, default: nil],
                                           retryCB: {await searchModel.fetchRecentlyViewedDetails(recentlyViewed: Array(history.prefix(15)))})
                        .equatable()
                    } else {
                        TrendingView(focusedTrend: $trendingModel.focusedTrend,
                                     cards: trendingModel.cards,
                                     products: trendingModel.products,
                                     trendingDataTaskStatuses: trendingModel.trendingDataTaskStatuses,
                                     trendingRequestErrors: trendingModel.trendingRequestErrors,
                                     fetchTrendingCards: trendingModel.fetchTrendingCards,
                                     fetchTrendingProducts: trendingModel.fetchTrendingProducts)
                        .equatable()
                    }
                case (.done, _), (.pending, _):
                    SearchResultsView(searchResults: searchModel.searchResults,
                                      requestError: searchModel.requestErrors[.search, default: nil],
                                      retryCB: {await searchModel.newSearchSubject(oldValue: searchModel.searchText, newValue: searchModel.searchText)})
                    .equatable()
                }
            }
            .onAppear {
                Task {
                    await searchModel.fetchRecentlyViewedDetails(recentlyViewed: Array(history.prefix(15)))
                }
            }
            .ygoNavigationDestination()
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchModel.searchText, isPresented: $searchModel.isSearching,
                        placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for card...")
            
        }
        .transaction {
            $0.animation = nil
        }
        .onChange(of: searchModel.searchText, initial: false) { oldValue, newValue in
            Task(priority: .userInitiated) {
                await searchModel.newSearchSubject(oldValue: oldValue, newValue: newValue)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .disableAutocorrection(true)
    }
}

#Preview("Card Search View") {
    SearchView()
}

private struct RecentlyViewedView: View, Equatable {
    nonisolated static func == (lhs: RecentlyViewedView, rhs: RecentlyViewedView) -> Bool {
        lhs.recentCards == rhs.recentCards && lhs.hasHistory == rhs.hasHistory && lhs.taskStatus == rhs.taskStatus && lhs.requestError == rhs.requestError
    }
    
    let recentCards: [Card]
    let hasHistory: Bool
    let taskStatus: DataTaskStatus
    let requestError: NetworkError?
    let retryCB: () async -> Void
    
    var body: some View {
        ScrollView {
            if !recentCards.isEmpty {
                SectionView(header: "Recently Viewed",
                            variant: .plain,
                            content: {
                    VStack {
                        ForEach(recentCards, id: \.cardID) { card in
                            NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
                                GroupBox() {
                                    CardListItemView(card: card)
                                        .equatable()
                                }
                                .groupBoxStyle(.listItem)
                            })
                            .buttonStyle(.plain)
                        }
                    }
                    .dynamicTypeSize(...DynamicTypeSize.medium)
                })
                .modifier(ParentViewModifier())
            }
        }
        .frame(maxWidth: .infinity)
        .overlay {
            if let requestError {
                NetworkErrorView(error: requestError, action: {
                    Task {
                        await retryCB()
                    }
                })
            } else {
                switch taskStatus {
                case .uninitiated, .pending:
                    ProgressView("Loading...")
                        .controlSize(.large)
                case .done where !hasHistory:
                    ContentUnavailableView {
                        Label("Type to search 😉", systemImage: "text.magnifyingglass")
                    }
                default:
                    EmptyView()
                }
            }
        }
    }
}

private struct SearchResultsView: View, Equatable {
    nonisolated static func == (lhs: SearchResultsView, rhs: SearchResultsView) -> Bool {
        lhs.searchResults == rhs.searchResults && lhs.requestError == rhs.requestError
    }
    
    let searchResults: [SearchResults]
    let requestError: NetworkError?
    let retryCB: () async -> Void
    
    var body: some View {
        VStack {
            if requestError == nil {
                List(searchResults) { sr in
                    Section(header:  Text(sr.section)
                        .font(.headline)
                        .fontWeight(.black) ) {
                            ForEach(sr.results, id: \.cardID) { card in
                                NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
                                    CardListItemView(card: card)
                                        .equatable()
                                })
                            }
                        }
                }
                .ignoresSafeArea(.keyboard)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            if let networkError = requestError {
                if networkError == .notFound {
                    ContentUnavailableView.search
                } else if networkError != .cancelled {
                    NetworkErrorView(error: networkError, action: {
                        Task {
                            await retryCB()
                        }
                    })
                }
            }
        }
        .listStyle(.plain)
    }
}
