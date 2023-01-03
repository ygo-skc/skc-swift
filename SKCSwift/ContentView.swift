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
        ScrollView {
            VStack {
                AsyncImage(url: imageUrl) { image in
                    let width = UIScreen.main.bounds.width - 20
                    image.resizable()
                        .frame(width: width, height: width)
                        .cornerRadius(50.0)
                } placeholder: {
                    Text("Loading...")
                }
                
                CardStats(cardName: cardData.cardName, monsterType: cardData.monsterType, cardEffect: cardData.cardEffect, monsterAssociation: cardData.monsterAssociation, cardId: cardData.cardID)
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
}

struct CardStats: View {
    var cardName: String
    var monsterType: String?
    var cardEffect: String
    var monsterAssociation: MonsterAssociation?
    var cardId: String
    
    var body: some View {
        VStack {
            VStack  {
                Text(cardName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white.opacity(0.9))
                    .bold()
                
                if (monsterAssociation != nil){
                    MonsterAssociationView(level: monsterAssociation!.level!)
                }
                
                VStack {
                    VStack(alignment: .leading) {
                        if (monsterType != nil) {
                            Text(monsterType!)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.leading)
                                .bold()
                                .padding(.bottom, 1.0)
                        }
                        Text(cardEffect)
                            .font(.footnote)
                            .fontWeight(.light)
                            .multilineTextAlignment(.leading)
                            .bold()
                        
                        HStack {
                            Text(cardId)
                                .font(.footnote)
                                .fontWeight(.thin)
                        }
                    }.padding(5)
                }.background(Color.white.opacity(0.85)).cornerRadius(10)
                
            }.padding(.all, 5.0).frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .topLeading
            )
        }.background(Color(red: 0.494, green: 0.342, blue: 0.762)).cornerRadius(10)
    }
}

struct MonsterAssociationView: View {
    var level: Int
    let iconSize = 30.0
    let iconRadius = 30.0
    
    var body: some View {
        HStack {
            Spacer()
            HStack {
                AsyncImage(url: URL(string: "https://thesupremekingscastle.com/assets/Light.svg"))
                    .frame(width: iconSize, height: iconSize)
                    .cornerRadius(iconRadius)
                AsyncImage(url: URL(string: "https://thesupremekingscastle.com/assets/Light.svg"))
                    .frame(width: iconSize, height: iconSize)
                    .cornerRadius(iconRadius)
                Text("x\(level)")
                    .fontWeight(.semibold)
            }.padding(.vertical, 5.0).padding(.horizontal, 15).background(Color.white.opacity(0.95)).cornerRadius(50.0)
            Spacer()
        }
    }
}

struct CardInfo_Previews: PreviewProvider {
    static var previews: some View {
        CardInfo()
    }
}
