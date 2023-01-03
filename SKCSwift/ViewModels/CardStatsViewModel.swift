//
//  CardStatsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import SwiftUI

struct CardStatsViewModel: View {
    var cardName: String
    var monsterType: String?
    var cardEffect: String
    var monsterAssociation: MonsterAssociation?
    var cardId: String
    
    let darkBackground = Color(red: 0.221, green: 0.133, blue: 0.37)
    let lightBackground = Color(red: 0.494, green: 0.342, blue: 0.762)
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            VStack  {
                Text(cardName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white.opacity(0.9))
                    .bold()
                
                if (monsterAssociation != nil){
                    MonsterAssociationViewModel(level: monsterAssociation!.level!)
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
                                .fontWeight(.light)
                        }.padding(.top, 1)
                    }.padding(5)
                }.background(colorScheme == .light ? Color.white.opacity(0.85): Color.black.opacity(0.5)).cornerRadius(10)
            }.padding(.horizontal, 5.0)
                .padding(.vertical, 10.0)
        }.background(colorScheme == .light ? lightBackground : darkBackground).cornerRadius(10).frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

struct CardStatsViewModel_Previews: PreviewProvider {
    static var previews: some View {
        CardStatsViewModel(cardName: "Elemental HERO Neos Kluger", monsterType: "Spellcaster/Fusion/Effect", cardEffect: "\"Elemental HERO Neos\" + \"Yubel\"\nMust be Fusion Summoned. Before damage calculation, if this card battles an opponent's monster: You can inflict damage to your opponent equal to that opponent's monster's ATK. If this face-up card is destroyed by battle, or leaves the field because of an opponent's card effect while its owner controls it: You can Special Summon 1 \"Neos Wiseman\" from your hand or Deck, ignoring its Summoning conditions. You can only use this effect of \"Elemental HERO Neos Kluger\" once per turn.", cardId: "90307498")
    }
}
