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
                switch searchViewModel.status {
                case .done, .pending, .uninitiated, .timeout:
                    if searchViewModel.status == .uninitiated || searchViewModel.searchText.isEmpty {
                        TrendingView(model: trendingViewModel)
                    } else if !searchViewModel.searchResults.isEmpty {
                        SearchResultsView(searchResults: searchViewModel.searchResults)
                            .equatable()
                    } else if searchViewModel.status == .done && !searchViewModel.searchText.isEmpty && searchViewModel.searchResults.isEmpty {
                        ContentUnavailableView.search
                    }
                case .error:
                    Text("Error")
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
        .onChange(of: searchViewModel.searchText, initial: false) { _, newValue in
            Task(priority: .userInitiated) {
                await searchViewModel.newSearchSubject(value: newValue)
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
