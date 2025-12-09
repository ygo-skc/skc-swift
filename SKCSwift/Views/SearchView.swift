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
                        .pending where searchModel.searchText.isEmpty:
                    if searchModel.isSearching {
                        RecentlyViewedView(path: $path,
                                           history: history,
                                           recentlyViewedCardDetails: recentlyViewedModel.recentlyViewedCardDetails,
                                           recentlyViewedSuggestions: recentlyViewedModel.recentlyViewedSuggestions,
                                           dataTaskStatus: recentlyViewedModel.dataTaskStatus,
                                           requestError: recentlyViewedModel.requestError,
                                           loadDataCB: { await recentlyViewedModel.fetchRecentlyViewedDetails(recentlyViewed: history) })
                        .equatable()
                    } else {
                        TrendingView(path: $path, trendingModel: $trendingModel)
                    }
                case .pending where searchModel.isSearchSlow:
                    ProgressView("Loading...")
                        .controlSize(.large)
                case .done, .pending, .error:
                    SearchResultsView(
                        path: $path,
                        results: searchModel.searchResults,
                        dataTaskStatus: searchModel.dataTaskStatus,
                        requestError: searchModel.requestError,
                        retryCB: { await searchModel.searchDB(oldValue: searchModel.searchText, newValue: searchModel.searchText) })
                    .equatable()
                }
            }
            .ignoresSafeArea(.keyboard)
            .ygoNavigationDestination()
            .navigationTitle("Search & Trending")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: searchModel.searchText, initial: false) { oldValue, newValue in
                Task {
                    await searchModel.searchDB(oldValue: oldValue, newValue: newValue)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .disableAutocorrection(true)
            .searchable(text: $searchModel.searchText,
                        isPresented: $searchModel.isSearching,
                        placement: .toolbar,
                        prompt: "Search for card...")
        }
    }
    
    private struct RecentlyViewedView: View, Equatable {
        static func == (lhs: RecentlyViewedView, rhs: RecentlyViewedView) -> Bool {
            lhs.history == rhs.history
            && lhs.dataTaskStatus == rhs.dataTaskStatus
            && lhs.requestError == rhs.requestError
            && lhs.recentlyViewedCardDetails == rhs.recentlyViewedCardDetails
        }
        
        @Binding var path: NavigationPath
        let history: [History]
        let recentlyViewedCardDetails: [Card]
        let recentlyViewedSuggestions: [CardReference]
        let dataTaskStatus: DataTaskStatus
        let requestError: NetworkError?
        let loadDataCB: () async -> Void
        
        var body: some View {
            ScrollView {
                if !recentlyViewedCardDetails.isEmpty {
                    SectionView(header: "History",
                                variant: .plain,
                                content: {
                        LazyVStack(alignment: .leading) {
                            if !recentlyViewedSuggestions.isEmpty {
                                Label("Personalized suggestions", systemImage: "sparkles")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                SuggestionCarouselView(references: recentlyViewedSuggestions, variant: .support)
                                    .padding(.bottom)
                            }
                            
                            
                            Label("Recently viewed", systemImage: "clock.arrow.circlepath")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            ForEach(recentlyViewedCardDetails, id: \.cardID) { card in
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
                await loadDataCB()
            }
            .dynamicTypeSize(...DynamicTypeSize.medium)
            .frame(maxWidth: .infinity)
            .overlay {
                if let requestError = requestError {
                    NetworkErrorView(error: requestError, action: {
                        Task {
                            await loadDataCB()
                        }
                    })
                } else if DataTaskStatusParser.isDataPending(dataTaskStatus) {
                    ProgressView("Loading...")
                        .controlSize(.large)
                } else if dataTaskStatus == .done && history.isEmpty {
                    ContentUnavailableView {
                        Label("Type to search 😉", systemImage: "text.magnifyingglass")
                    }
                }
            }
        }
    }
    
    private struct SearchResultsView: View, Equatable {
        static func == (lhs: SearchResultsView, rhs: SearchResultsView) -> Bool {
            lhs.dataTaskStatus == rhs.dataTaskStatus
            && lhs.requestError == rhs.requestError
        }
        
        @Binding var path: NavigationPath
        let results: [SearchResults]
        let dataTaskStatus: DataTaskStatus
        let requestError: NetworkError?
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
                if !DataTaskStatusParser.isDataPending(dataTaskStatus), let networkError = requestError {
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
