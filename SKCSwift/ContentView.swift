//
//  ContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/1/23.
//

import SwiftUI

let card = "90307498"
let imageUrl = URL(string: "https://images.thesupremekingscastle.com/cards/lg/\(card).jpg")
var cardData = Card(cardID: "", cardName: "Elemental HERO Neos Kluger", cardColor: "", cardAttribute: "", cardEffect: "\"Elemental HERO Neos\" + \"Yubel\"Must be Fusion Summoned. Before damage calculation, if this card battles an opponent's monster: You can inflict damage to your opponent equal to that opponent's monster's ATK. If this face-up card is destroyed by battle, or leaves the field because of an opponent's card effect while its owner controls it: You can Special Summon 1 \"Neos Wiseman\" from your hand or Deck, ignoring its Summoning conditions. You can only use this effect of \"Elemental HERO Neos Kluger\" once per turn.", monsterType: "Warrior/Fusion/Effect")

struct CardInfo: View {
    init () {
        getCardData(cardId: card, {result in
            switch result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    var body: some View {
        VStack {
            Text(cardData.cardName)
                .font(.title)
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
    }
}

struct CardInfo_Previews: PreviewProvider {
    static var previews: some View {
        CardInfo()
    }
}
