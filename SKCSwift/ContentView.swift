//
//  ContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/1/23.
//

import SwiftUI

let card = "90307498"
let imageUrl = URL(string: "https://images.thesupremekingscastle.com/cards/original/90307498.jpg")!

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView().tabItem{
                Image(systemName: "house.fill")
            }
            CardView().tabItem{
                Image(systemName: "camera.macro.circle.fill")
            }
            SearchCard().tabItem{
                Image(systemName: "magnifyingglass.circle.fill")
            }
        }
    }
}

struct SearchCard: View {
    @State var searchResults: [Card] = []
    @State var searchText = ""
    
    var body: some View {
        NavigationStack {
            List(searchResults, id: \.cardID) { card in
                VStack {
                    Text(card.cardName)
                    if (card.monsterType != nil) {
                        Text(card.monsterType!)
                    }
                }
            }.listStyle(.plain).searchable(text: $searchText)
                .onChange(of: searchText) { value in
                    searchCard(searchTerm: value.trimmingCharacters(in: .whitespacesAndNewlines), {result in
                        switch result {
                        case .success(let card):
                            self.searchResults = card
                        case .failure(let error):
                            print(error)
                        }
                    })
                }.navigationTitle("Search")
        }
    }
}

struct HomeView: View {
    let screenWidth = UIScreen.main.bounds.width - 10
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading) {
                Text("Home").fontWeight(.heavy)
                    .font(.largeTitle)
                Text("Content").fontWeight(.bold)
                    .font(.title3)
                Text("The SKC Database has 1,000 cards, 36 ban lists and 200 products.").fontWeight(.regular)
                    .font(.headline)
            }.frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .onAppear {
            }
        }.frame(width: screenWidth)
    }
}

struct CardView: View {
    @State private var cardData = Card(cardID: "", cardName: "", cardColor: "", cardAttribute: "", cardEffect: "", monsterType: "")
    @State private var showView = false
    @State private var isDataLoaded = false
    let screenWidth = UIScreen.main.bounds.width - 10
    let imageSize = UIScreen.main.bounds.width - 30
    
    var body: some View {
        ScrollView {
            VStack {
                RoundedRectImage(width: imageSize, height: imageSize, imageUrl: imageUrl)
                if (isDataLoaded) {
                    CardStatsViewModel(cardName: cardData.cardName, monsterType: cardData.monsterType, cardEffect: cardData.cardEffect, monsterAssociation: cardData.monsterAssociation, cardId: cardData.cardID, cardAttribute: cardData.cardAttribute)
                } else {
                    RectPlaceholderViewModel(width: screenWidth, height: 200, radius: 10)
                }
            }
            .onAppear {
                getCardData(cardId: card, {result in
                    switch result {
                    case .success(let card):
                        self.cardData = card
                        self.isDataLoaded = true
                    case .failure(let error):
                        print(error)
                    }
                })
            }
            
            Button {
                showView.toggle()
            } label: {
                Text("Suggestions")
                    .font(.title3)
            }
            .sheet(isPresented: $showView) {
                Text("Yo")
            }
            
        }.frame(width: screenWidth)
    }
}


struct CardInfo_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
