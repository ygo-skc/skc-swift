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
                switch (searchModel.dataTaskStatus, searchModel.requestError) {
                case (.done, .notFound), (.pending, .notFound):
                    ContentUnavailableView.search
                case (.done, _) where searchModel.searchText.isEmpty,
                    (.pending, _) where searchModel.searchText.isEmpty,
                    (.uninitiated, _):
                    if searchModel.isSearching {
                        RecentlyViewedView(recentCards: searchModel.recentlyViewedCardDetails, hasHistory: !history.isEmpty)
                    } else {
                        TrendingView(model: trendingModel)
                    }
                case (.done, _), (.pending, _):
                    if let error = searchModel.requestError, error != .cancelled {
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
            .navigationDestination(for: CardLinkDestinationValue.self) { card in
                CardLinkDestinationView(cardLinkDestinationValue: card)
            }
            .navigationDestination(for: ProductLinkDestinationValue.self) { product in
                ProductLinkDestinationView(productLinkDestinationValue: product)
            }
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
    
    var body: some View {
        ScrollView {
            if !recentCards.isEmpty {
                SectionView(header: "Recently Viewed",
                            variant: .plain,
                            content: {
                    LazyVStack {
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
            if !hasHistory {
                ContentUnavailableView {
                    Label("Type to search 😉", systemImage: "text.magnifyingglass")
                }
            } else if recentCards.isEmpty {
                ProgressView("Loading...")
                    .controlSize(.large)
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
