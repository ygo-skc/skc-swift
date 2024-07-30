//
//  SearchCardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var searchViewModel: SearchViewModel
    @StateObject private var trendingViewModel: TrendingViewModel
    
    init() {
        _searchViewModel = StateObject(wrappedValue: SearchViewModel())
        _trendingViewModel = StateObject(wrappedValue: TrendingViewModel())
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if (!searchViewModel.searchResults.isEmpty) {
                    List(searchViewModel.searchResults) { sr in
                        Section(header: HStack{
                            CardColorIndicator(cardColor: sr.section)
                                .equatable()
                            Text(sr.section)
                        }
                            .font(.headline)
                            .fontWeight(.black) ) {
                                ForEach(sr.results, id: \.cardID) { card in
                                    NavigationLink(value: CardValue(cardID: card.cardID, cardName: card.cardName), label: {
                                        CardListItemView(cardID: card.cardID, cardName: card.cardName, monsterType: card.monsterType)
                                    })
                                }
                            }
                    }
                    .scrollDismissesKeyboard(.immediately)
                    .listStyle(.plain)
                    .ignoresSafeArea(.keyboard)
                } else {
                    if !searchViewModel.searchText.isEmpty && searchViewModel.searchResults.isEmpty {
                        Text("Nothing found in database")
                            .font(.title2)
                            .frame(alignment: .center)
                    } else if searchViewModel.searchText.isEmpty {
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
            .navigationDestination(for: CardValue.self) { card in
                CardSearchLinkDestination(cardValue: card)
            }
            .navigationTitle("Search")
            .task(priority: .low) {
                trendingViewModel.fetchTrendingData()
            }
        }
        .searchable(text: $searchViewModel.searchText, prompt: "Search for card...")
        .onChange(of: searchViewModel.searchText, initial: false) { _, newValue in
            searchViewModel.newSearchSubject(value: newValue)
        }
        .disableAutocorrection(true)
    }
}

#Preview("Card Search View") {
    SearchView()
}
