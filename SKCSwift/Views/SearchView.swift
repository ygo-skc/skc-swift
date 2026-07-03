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
    
    @Query(ArchiveContainer.fetchHistoryByAccessDate(sortOrder: .reverse, limit: 20)) private var history: [History]
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                switch searchModel.dataTaskStatus {
                case .done where searchModel.searchText.isEmpty,
                        .pending where searchModel.searchText.isEmpty:
                    RecentlyViewedView(history: history, model: recentlyViewedModel)
                    .equatable()
                case .pending where searchModel.isSearchSlow:
                    ProgressView("Loading…")
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
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
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
                        prompt: "Search for card…")
        }
    }
    
    private struct RecentlyViewedView: View, Equatable {
        static func == (lhs: RecentlyViewedView, rhs: RecentlyViewedView) -> Bool {
            lhs.history == rhs.history
            && lhs.model.dataTaskStatus == rhs.model.dataTaskStatus
            && lhs.model.requestError == rhs.model.requestError
            && lhs.model.recentlyViewedCardDetails == rhs.model.recentlyViewedCardDetails
        }
        
        let history: [History]
        let model: RecentlyViewedViewModel
        
        var body: some View {
            ScrollView {
                if !model.recentlyViewedCardDetails.isEmpty {
                    LazyVStack(alignment: .leading, spacing: 25) {
                        if !model.recentlyViewedSuggestions.isEmpty {
                            VStack(alignment: .leading) {
                                Label("Suggestions", systemImage: "sparkles")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                SuggestionCarouselView(references: model.recentlyViewedSuggestions, variant: .support)
                            }
                        }
                        
                        YGOArchetypesView(title: "Suggested archetypes",
                                          archetypes: model.recentlyViewedArchetypeSuggestions,
                                          showBetaBadge: true)
                        
                        VStack(alignment: .leading) {
                            Label("Recently viewed", systemImage: "clock.arrow.circlepath")
                                .font(.headline)
                                .fontWeight(.medium)
                            CardListView(cards: model.recentlyViewedCardDetails)
                                .equatable()
                        }
                    }
                    .modifier(.parentView)
                }
            }
            .task {
                await model.fetchRecentlyViewedDetails(recentlyViewed: history)
            }
            .dynamicTypeSize(...DynamicTypeSize.medium)
            .frame(maxWidth: .infinity) // needed by overlay
            .overlay {
                if let requestError = model.requestError {
                    NetworkErrorView(error: requestError, action: {
                        Task {
                            await model.fetchRecentlyViewedDetails(recentlyViewed: history)
                        }
                    })
                } else if DataTaskStatusParser.isDataPending(model.dataTaskStatus) {
                    ProgressView("Loading…")
                        .controlSize(.large)
                } else if model.dataTaskStatus == .done && history.isEmpty {
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
            Group {
                if requestError == nil {
                    List(results) { sr in
                        Section(header: Text(sr.section)
                            .font(.headline)
                            .fontWeight(.black)) {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)   // needed by overlay
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
