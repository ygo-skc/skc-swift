//
//  SearchView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @State private var path = NavigationPath()
    @State private var recentlyViewedModel = RecentlyViewedViewModel()
    @State private var searchModel = SearchViewModel()
    @State private var trendingModel = TrendingViewModel()
    
    @Query(ArchiveContainer.fetchHistoryByAccessDate(sortOrder: .reverse, limit: 20)) private var history: [History]
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                switch searchModel.dataTaskStatus {
                case .done where searchModel.searchText.isEmpty,
                        .pending where searchModel.searchText.isEmpty,
                        .uninitiated:
                    if searchModel.isSearching {
                        RecentlyViewedView(path: $path, recentlyViewedModel: recentlyViewedModel, history: history)
                    } else {
                        TrendingView(path: $path, trendingModel: $trendingModel)
                    }
                case .done, .pending, .error:
                    SearchResultsView(
                        path: $path,
                        requestError: searchModel.requestError,
                        results: searchModel.searchResults,
                        retryCB: { await searchModel.searchDB(oldValue: searchModel.searchText, newValue: searchModel.searchText) })
                }
            }
            .ignoresSafeArea(.keyboard)
            .ygoNavigationDestination()
            .navigationTitle("Search & Trending")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchModel.searchText, isPresented: $searchModel.isSearching,
                        placement: .toolbar, prompt: "Search for card...")
        }
        .onChange(of: searchModel.searchText, initial: false) { oldValue, newValue in
            Task {
                await searchModel.searchDB(oldValue: oldValue, newValue: newValue)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .disableAutocorrection(true)
    }
    
    private struct RecentlyViewedView: View {
        @Binding var path: NavigationPath
        let recentlyViewedModel: RecentlyViewedViewModel
        let history: [History]
        
        var body: some View {
            ScrollView {
                if !recentlyViewedModel.recentlyViewedCardDetails.isEmpty {
                    SectionView(header: "History",
                                variant: .plain,
                                content: {
                        LazyVStack(alignment: .leading) {
                            if !recentlyViewedModel.recentlyViewedSuggestions.isEmpty {
                                Label("Personalized suggestions", systemImage: "sparkles")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                SuggestionCarouselView(references: recentlyViewedModel.recentlyViewedSuggestions, variant: .support)
                                    .padding(.bottom)
                            }
                            
                            
                            Label("Recently viewed", systemImage: "clock.arrow.circlepath")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            ForEach(recentlyViewedModel.recentlyViewedCardDetails, id: \.cardID) { card in
                                Button {
                                    path.append(CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName))
                                } label: {
                                    GroupBox() {
                                        CardListItemView(card: card)
                                            .equatable()
                                    }
                                    .groupBoxStyle(.listItem)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    })
                    .modifier(.parentView)
                }
            }
            .task {
                await recentlyViewedModel.fetchRecentlyViewedDetails(recentlyViewed: Array(history.prefix(15)))
            }
            .dynamicTypeSize(...DynamicTypeSize.medium)
            .frame(maxWidth: .infinity)
            .overlay {
                if let requestError = recentlyViewedModel.requestError {
                    NetworkErrorView(error: requestError, action: {
                        Task {
                            await recentlyViewedModel.fetchRecentlyViewedDetails(recentlyViewed: history)
                        }
                    })
                } else {
                    switch recentlyViewedModel.dataTaskStatus {
                    case .uninitiated, .pending:
                        ProgressView("Loading...")
                            .controlSize(.large)
                    case .done where history.isEmpty:
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
    
    private struct SearchResultsView: View {
        @Binding var path: NavigationPath
        let requestError: NetworkError?
        let results: [SearchResults]
        let retryCB: () async -> Void
        
        var body: some View {
            VStack {
                if requestError == nil {
                    List(results) { sr in
                        Section(header:  Text(sr.section)
                            .font(.headline)
                            .fontWeight(.black) ) {
                                ForEach(sr.results, id: \.cardID) { card in
                                    CardListItemView(card: card)
                                        .equatable()
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            path.append(CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName))
                                        }
                                }
                            }
                    }
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
        }
    }
}

#Preview("Card Search View") {
    SearchView()
}
