//
//  ContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/1/23.
//

import SwiftUI

let card = "90307498"
let imageUrl = URL(string: "https://images.thesupremekingscastle.com/cards/original/90307498.jpg")!

struct CardInfo: View {
    @State private var cardData = Card(cardID: "", cardName: "", cardColor: "", cardAttribute: "", cardEffect: "", monsterType: "")
    @State private var showView = false
    @State private var isDataLoaded = false
    let screenWidth = UIScreen.main.bounds.width - 10
    
    var body: some View {
        ScrollView {
            VStack {
                RoundedRectImage(width: screenWidth - 10, height: screenWidth, imageUrl: imageUrl)
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
        }.frame(width: screenWidth)
        
        ZStack {
            Button {
                showView.toggle()
            } label: {
                Text("Suggestions")
                    .font(.title3)
            }
            .sheet(isPresented: $showView) {
                Text("Yo")
            }
        }
    }
}

struct CardInfo_Previews: PreviewProvider {
    static var previews: some View {
        CardInfo()
    }
}
