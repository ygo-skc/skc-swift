//
//  ContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/1/23.
//

import SwiftUI

let card = "90307498"
let imageUrl = URL(string: "https://images.thesupremekingscastle.com/cards/original/\(card).jpg")

struct CardInfo: View {
    @State private var cardData = Card(cardID: "", cardName: "", cardColor: "", cardAttribute: "", cardEffect: "", monsterType: "")
    
    var body: some View {
        VStack {
            Text(cardData.cardName)
                .font(.title2)
                .multilineTextAlignment(.leading)
                .bold()
            
            
            
            AsyncImage(url: imageUrl) { image in
                let width = UIScreen.main.bounds.width - 20
                image.resizable()
                    .frame(width: width, height: width)
                    .cornerRadius(50.0)
            } placeholder: {
                Text("Loading...")
            }
            
            CardStats(monsterType: cardData.monsterType, cardEffect: cardData.cardEffect, monsterAssociation: cardData.monsterAssociation)
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

struct CardStats: View {
    var monsterType: String?
    var cardEffect: String
    var monsterAssociation: MonsterAssociation?
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                if (monsterAssociation != nil){
                    MonsterAssociationView(level: monsterAssociation!.level!)
                }
                
                if (monsterType != nil) {
                    Text(monsterType!)
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .bold()
                        .padding(.bottom, 1.0)
                }
                Text(cardEffect)
                    .font(.footnote)
                    .fontWeight(.light)
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

struct MonsterAssociationView: View {
    var level: Int
    
    var body: some View {
        HStack {
            Spacer()
            AsyncImage(url: URL(string: "https://thesupremekingscastle.com/assets/Light.svg"))
                .frame(width: 50, height: 50)
                .cornerRadius(50.0)
            AsyncImage(url: URL(string: "https://thesupremekingscastle.com/assets/Light.svg"))
                .frame(width: 50, height: 50)
                .cornerRadius(50.0)
            Text("X\(level)")
                .fontWeight(.bold)
            Spacer()
        }
    }
}

struct CardInfo_Previews: PreviewProvider {
    static var previews: some View {
        CardInfo()
    }
}
