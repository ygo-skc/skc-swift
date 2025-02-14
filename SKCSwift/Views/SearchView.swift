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
    
    @Query(sort: \History.lastAccessDate, order: .reverse) private var history: [History]
    
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
                        RecentlyBrowsedView(recentCards: searchModel.recentlyBrowsedDetails)
                            .task {
                                await searchModel.fetchRecentlyBrowsedDetails(recentlyBrowsed: Array(history.prefix(15)))
                            }
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
            .navigationDestination(for: CardLinkDestinationValue.self) { card in
                CardLinkDestinationView(cardLinkDestinationValue: card)
            }
            .navigationDestination(for: ProductLinkDestinationValue.self) { product in
                ProductLinkDestinationView(productLinkDestinationValue: product)
            }
            .navigationTitle("Search")
        }
        .transaction {
            $0.animation = nil
        }
        .searchable(text: $searchModel.searchText, isPresented: $searchModel.isSearching, prompt: "Search for card...")
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

private struct RecentlyBrowsedView: View {
    let recentCards: [Card]
    
    var body: some View {
        ScrollView {
            if !recentCards.isEmpty {
                SectionView(header: "Recently Browsed",
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
            if recentCards.isEmpty {
                ContentUnavailableView {
                    Label("Type to search 😉", systemImage: "text.magnifyingglass")
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
