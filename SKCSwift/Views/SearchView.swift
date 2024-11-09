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
                switch searchViewModel.dataTaskStatus {
                case .done where searchViewModel.requestError == .notFound,
                        .pending where searchViewModel.requestError == .notFound:
                    ContentUnavailableView.search
                case .done where !searchViewModel.searchText.isEmpty && !searchViewModel.searchResults.isEmpty, .pending:
                    SearchResultsView(searchResults: searchViewModel.searchResults)
                        .equatable()
                case .done, .uninitiated:
                    TrendingView(model: trendingViewModel)
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
