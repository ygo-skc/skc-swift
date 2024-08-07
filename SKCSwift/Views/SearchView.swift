//
//  SearchView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText: String
    @StateObject private var searchViewModel: SearchViewModel
    @StateObject private var trendingViewModel: TrendingViewModel
    
    init() {
        _searchText = State(initialValue: "")
        _searchViewModel = StateObject(wrappedValue: SearchViewModel())
        _trendingViewModel = StateObject(wrappedValue: TrendingViewModel())
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if !searchViewModel.searchResults.isEmpty {
                    List(searchViewModel.searchResults) { sr in
                        Section(header: HStack{
                            CardColorIndicatorView(cardColor: sr.section)
                                .equatable()
                            Text(sr.section)
                        }
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
                } else {
                    if !searchText.isEmpty && searchViewModel.searchResults.isEmpty {
                        Text("Nothing found in database")
                            .font(.title2)
                            .frame(alignment: .center)
                    } else if searchText.isEmpty {
                        ScrollView() {
                            if let cards = trendingViewModel.cards, let products = trendingViewModel.products {
                                TrendingView(cardTrendingData: cards, productTrendingData: products)
                                    .equatable()
                                    .modifier(ParentViewModifier())
                            } else {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            }
                        }
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
            .task(priority: .low) {
                trendingViewModel.fetchTrendingData()
            }
        }
        .searchable(text: $searchText, prompt: "Search for card...")
        .onChange(of: searchText, initial: false) { _, newValue in
            searchViewModel.newSearchSubject(value: newValue)
        }
        .disableAutocorrection(true)
    }
}

#Preview("Card Search View") {
    SearchView()
}
