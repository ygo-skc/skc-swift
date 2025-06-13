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
    
    @State private var path = NavigationPath()
    @State private var recentlyViewedModel = RecentlyViewedViewModel()
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
        NavigationStack(path: $path) {
            VStack {
                switch (searchModel.dataTaskStatus, searchModel.requestError) {
                case (.done, _) where searchModel.searchText.isEmpty,
                    (.pending, _) where searchModel.searchText.isEmpty,
                    (.uninitiated, _):
                    if searchModel.isSearching {
                        RecentlyViewedView(path: $path, recentlyViewedModel: recentlyViewedModel, history: Array(history.prefix(15)))
                    } else {
                        TrendingView(path: $path, trendingModel: $trendingModel)
                    }
                case (.done, _), (.pending, _):
                    SearchResultsView(path: $path, searchModel: searchModel)
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
            Task {
                await searchModel.searchDB(oldValue: oldValue, newValue: newValue)
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
                            Text("Suggestions")
                                .font(.headline)
                                .fontWeight(.medium)
                            SuggestionCarouselView(references: recentlyViewedModel.recentlyViewedSuggestions, variant: .support)
                                .padding(.bottom)
                        }
                        
                        Text("Recently viewed")
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
    let searchModel: SearchViewModel
    
    var body: some View {
        VStack {
            if searchModel.requestError == nil {
                List(searchModel.searchResults) { sr in
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
                .ignoresSafeArea(.keyboard)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            if let networkError = searchModel.requestError {
                if networkError == .notFound {
                    ContentUnavailableView.search
                } else if networkError != .cancelled {
                    NetworkErrorView(error: networkError, action: {
                        Task {
                            await searchModel.searchDB(oldValue: searchModel.searchText, newValue: searchModel.searchText)
                        }
                    })
                }
            }
        }
        .listStyle(.plain)
    }
}
