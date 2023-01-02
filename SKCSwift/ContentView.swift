//
//  ContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/1/23.
//

import SwiftUI

let card = "90307498"
let imageUrl = URL(string: "https://images.thesupremekingscastle.com/cards/lg/\(card).jpg")

struct CardInfo: View {
    @State private var cardData = Card(cardID: "", cardName: "", cardColor: "", cardAttribute: "", cardEffect: "", monsterType: "")
    
    var body: some View {
        VStack {
            Text(cardData.cardName)
                .font(.title2)
                .multilineTextAlignment(.leading)
                .bold()
            AsyncImage(url: imageUrl)
                .frame(width: 350, height: 350)
                .cornerRadius(50.0)
            
            VStack(alignment: .leading) {
                Text(cardData.monsterType!)
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .bold()
                    .padding(.bottom, 1.0)
                Text(cardData.cardEffect)
                    .font(.body)
                    .fontWeight(.regular)
                    .multilineTextAlignment(.leading)
                    .bold()
            }.padding(.horizontal, 12.0).frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .topLeading
            )
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
}

struct CardInfo_Previews: PreviewProvider {
    static var previews: some View {
        CardInfo()
    }
}
