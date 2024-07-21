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
                            Text(sr.section)
                        }
                            .font(.headline)
                            .fontWeight(.black) ) {
                                ForEach(sr.results, id: \.cardID) { card in
                                    NavigationLink(value: CardValue(cardID: card.cardID, cardName: card.cardName), label: {
                                        CardSearchResultView(cardID: card.cardID, cardName: card.cardName, monsterType: card.monsterType)
                                    })
                                }
                            }
                    }
                    .scrollDismissesKeyboard(.immediately)
                    .listStyle(.plain)
                    .ignoresSafeArea(.keyboard)
                } else {
                    VStack {
                        if (!cardSearchViewModel.isFetching && !cardSearchViewModel.searchText.isEmpty) {
                            Text("Nothing found in database")
                                .font(.title2)
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity,
                                    alignment: .center
                                )
                        } else {
                            SectionView(header: "Trending",
                                        variant: .plain,
                                        content: {
                                VStack(alignment: .leading, spacing: 5) {
                                }
                                .frame(maxHeight: .infinity)
                            })
                        }
                    }
                    .padding(.horizontal)
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

private struct CardSearchResultView: View {
    var cardID: String
    var cardName: String
    var monsterType: String?
    
    var body: some View {
        HStack(alignment: .top) {
            YGOCardImage(height: 60, imgSize: .tiny, cardID: cardID)
            VStack(alignment: .leading) {
                Text(cardName)
                    .fontWeight(.bold)
                    .font(.subheadline)
                    .lineLimit(2)
                if monsterType != nil {
                    Text(monsterType!)
                        .fontWeight(.light)
                        .font(.callout)
                        .lineLimit(2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Card Search Result") {
    CardSearchResultView(cardID: "40044918", cardName: "Elemental HERO Stratos", monsterType: "Warrior/Effect")
}

#Preview("Card Search Result - IMG DNE") {
    CardSearchResultView(cardID: "08949584", cardName: "A HERO Lives")
}
