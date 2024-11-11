//
//  SearchView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct SearchView: View {
    @State private var searchViewModel = SearchViewModel()
    @State private var trendingViewModel = TrendingViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                switch (searchViewModel.dataTaskStatus, searchViewModel.requestError) {
                case (.done, .notFound), (.pending, .notFound):
                    ContentUnavailableView.search
                case (.done, _) where searchViewModel.searchText.isEmpty, (.pending, _) where searchViewModel.searchText.isEmpty, (.uninitiated, _):
                    TrendingView(model: trendingViewModel)
                case (.done, _), (.pending, _):
                    if let error = searchViewModel.requestError, error != .cancelled {
                        NetworkErrorView(error: error, action: {
                            Task {
                                await searchViewModel.newSearchSubject(oldValue: searchViewModel.searchText, newValue: searchViewModel.searchText)
                            }
                        })
                    } else {
                        SearchResultsView(searchResults: searchViewModel.searchResults)
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
        .searchable(text: $searchViewModel.searchText, prompt: "Search for card...")
        .onChange(of: searchViewModel.searchText, initial: false) { oldValue, newValue in
            Task(priority: .userInitiated) {
                await searchViewModel.newSearchSubject(oldValue: oldValue, newValue: newValue)
            }
        }
        .disableAutocorrection(true)
    }
}

#Preview("Card Search View") {
    SearchView()
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
        .scrollDismissesKeyboard(.immediately)
        .listStyle(.plain)
        .ignoresSafeArea(.keyboard)
    }
}
