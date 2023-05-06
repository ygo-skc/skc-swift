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
            if (!cardSearchViewModel.isFetching && !cardSearchViewModel.searchText.isEmpty && cardSearchViewModel.searchResults.isEmpty) {
                VStack {
                    Spacer()
                    Text("Nothing found in database")
                        .font(.title2)
                }
                .padding(.horizontal)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
            } else if (cardSearchViewModel.searchText.isEmpty) {
                VStack(alignment: .leading) {
                    Text("Suggestions")
                        .font(.title2)
                }
                .padding(.all)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
            }
            
            List(cardSearchViewModel.searchResults) { sr in
                Section(header: HStack{
                    Circle()
                        .foregroundColor(cardColorUI(cardColor: sr.section))
                        .frame(width: 15)
                    Text(sr.section)
                }
                    .font(.headline)
                    .fontWeight(.black) ) {
                        ForEach(sr.results, id: \.cardID) { card in
                            NavigationLink(destination: CardSearchLinkDestination(cardID: card.cardID), label: {
                                CardSearchResultView(cardID: card.cardID, cardName: card.cardName, monsterType: card.monsterType)
                            })
                            
                        }
                    }
            }
            .listStyle(.plain)
            .navigationTitle("Search")
            .searchable(text: $cardSearchViewModel.searchText, prompt: "Search for card...")
            .disableAutocorrection(true)
            .onChange(of: cardSearchViewModel.searchText, perform: cardSearchViewModel.newSearchSubject)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .ignoresSafeArea(.keyboard)
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

struct CardSearchLinkDestination: View {
    var cardID: String
    
    var body: some View {
        CardView(cardID: cardID)
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct SearchCardViewModel_Previews: PreviewProvider {
    static var previews: some View {
        CardSearchView()
    }
}


private struct CardSearchResultView: View {
    var cardID: String
    var cardName: String
    var monsterType: String?
    
    var body: some View {
        HStack(alignment: .top) {
            RoundedImageView(radius: 60, imageUrl: URL(string: "https://images.thesupremekingscastle.com/cards/tn/\(cardID).jpg")!)
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

struct CardSearchResultView_Previews: PreviewProvider {
    static var previews: some View {
        CardSearchResultView(cardID: "40044918", cardName: "Elemental HERO Stratos", monsterType: "Warrior/Effect")
        CardSearchResultView(cardID: "08949584", cardName: "A HERO Lives")
    }
}
