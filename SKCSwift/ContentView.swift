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
    
    var body: some View {
        ScrollView {
            VStack {
                let screenWidth = UIScreen.main.bounds.width - 20
                RoundedRectImage(width: screenWidth, height: screenWidth, imageUrl: imageUrl)
                CardStatsViewModel(cardName: cardData.cardName, monsterType: cardData.monsterType, cardEffect: cardData.cardEffect, monsterAssociation: cardData.monsterAssociation, cardId: cardData.cardID)
            }
            .onAppear {
                getCardData(cardId: card, {result in
                    switch result {
                    case .success(let card):
                        self.cardData = card
                    case .failure(let error):
                        print(error)
                    }
                })
            }
        }
        
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
