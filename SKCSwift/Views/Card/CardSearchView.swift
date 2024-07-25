//
//  SearchCardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct CardSearchView: View {
    @StateObject private var cardSearchViewModel = CardSearchViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if (!cardSearchViewModel.searchResults.isEmpty) {
                    List(cardSearchViewModel.searchResults) { sr in
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
                    if !cardSearchViewModel.isFetching && !cardSearchViewModel.searchText.isEmpty {
                        Text("Nothing found in database")
                            .padding(.horizontal)
                            .font(.title2)
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .center
                            )
                    } else if cardSearchViewModel.searchText.isEmpty {
                        TrendingView()
                    }
                }
            }
            .navigationDestination(for: CardValue.self) { card in
                CardSearchLinkDestination(cardValue: card)
            }
            .navigationTitle("Search")
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
        }
        .searchable(text: $cardSearchViewModel.searchText, prompt: "Search for card...")
        .onChange(of: cardSearchViewModel.searchText, initial: false) { _, newValue in
            cardSearchViewModel.newSearchSubject(value: newValue)
        }
        .disableAutocorrection(true)
    }
}

struct CardSearchLinkDestination: View {
    var cardValue: CardValue
    
    var body: some View {
        CardView(cardID: cardValue.cardID)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(cardValue.cardName)
    }
}

#Preview("Card Search View") {
    CardSearchView()
}
