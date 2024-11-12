//
//  SearchView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct SearchView: View {
    @State private var searchModel = SearchViewModel()
    @State private var trendingModel = TrendingViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                switch (searchModel.dataTaskStatus, searchModel.requestError) {
                case (.done, .notFound), (.pending, .notFound):
                    ContentUnavailableView.search
                case (.done, _) where searchModel.searchText.isEmpty, (.pending, _) where searchModel.searchText.isEmpty, (.uninitiated, _):
                    TrendingView(model: trendingModel)
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
        .searchable(text: $searchModel.searchText, prompt: "Search for card...")
        .onChange(of: searchModel.searchText, initial: false) { oldValue, newValue in
            Task(priority: .userInitiated) {
                await searchModel.newSearchSubject(oldValue: oldValue, newValue: newValue)
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
