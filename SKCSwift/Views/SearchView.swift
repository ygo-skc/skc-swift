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
                switch (searchModel.searchStatus, searchModel.searchError) {
                case (.done, .notFound), (.pending, .notFound):
                    ContentUnavailableView.search
                case (.done, _) where searchModel.searchText.isEmpty,
                    (.pending, _) where searchModel.searchText.isEmpty,
                    (.uninitiated, _):
                    if searchModel.isSearching {
                        RecentlyViewedView(recentCards: searchModel.recentlyViewedCardDetails, hasHistory: !history.isEmpty,
                                           taskStatus: searchModel.recentlyViewedStatus, requestError: searchModel.recentlyViewedError,
                                           retryCB: {await searchModel.fetchRecentlyViewedDetails(recentlyViewed: Array(history.prefix(15)))})
                    } else {
                        TrendingView(model: trendingModel)
                    }
                case (.done, _), (.pending, _):
                    if let error = searchModel.searchError, error != .cancelled {
                        NetworkErrorView(error: error, action: {
                            Task {
                                await searchModel.newSearchSubject(oldValue: searchModel.searchText, newValue: searchModel.searchText)
                            }
                        })
                    } else {
                        SearchResultsView(searchResults: searchModel.searchResults)
                            .equatable()
                    }
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
            .searchable(text: $searchModel.searchText, isPresented: $searchModel.isSearching, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for card...")
            
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

private struct RecentlyViewedView: View {
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
                            .dynamicTypeSize(...DynamicTypeSize.medium)
                            .buttonStyle(.plain)
                        }
                    }
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
    let searchResults: [SearchResults]
    
    var body: some View {
        List(searchResults) { sr in
            Section(header:  Text(sr.section)
                .font(.headline)
                .fontWeight(.black) ) {
                    ForEach(sr.results, id: \.cardID) { card in
                        NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
                            CardListItemView(card: card)
                        })
                    }
                }
        }
        .listStyle(.plain)
        .ignoresSafeArea(.keyboard)
    }
}
