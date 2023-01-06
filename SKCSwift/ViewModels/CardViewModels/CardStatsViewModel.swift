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
    var cardAttribute: String
    
    var body: some View {
        VStack {
            VStack  {
                Text(cardName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white.opacity(0.9))
                    .bold()
                
                let attribute = Attribute(rawValue: cardAttribute)
                if (monsterAssociation != nil && attribute != nil){
                    MonsterAssociationViewModel(monsterAssociation: monsterAssociation!, attribute: attribute!)
                        .padding(.top, -5.0)
                }
                
                VStack {
                    VStack(alignment: .leading) {
                        if (monsterType != nil) {
                            Text(monsterType!)
                                .font(.headline)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.leading)
                                .bold()
                                .padding(.bottom, 1.0)
                        }
                        
                        Text(cardEffect)
                            .font(.body)
                            .fontWeight(.light)
                            .multilineTextAlignment(.leading)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        
                        HStack {
                            Text(cardId)
                                .font(.footnote)
                                .fontWeight(.light)
                        }.padding(.top, 1)
                    }.padding(5)
                }.background(Color("TranslucentBackground"))
                    .cornerRadius(10)
            }.padding(.horizontal, 5.0)
                .padding(.vertical, 10.0)
        }.background(Color("Fusion"))
            .cornerRadius(15)
            .frame(
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
        let cardName = "Elemental HERO Neos Kluger"
        let monsterType = "Spellcaster/Fusion/Effect"
        //        let cardEffect = "yooo"
        let cardEffect = "\"Elemental HERO Neos\" + \"Yubel\"\nMust be Fusion Summoned. Before damage calculation, if this card battles an opponent's monster: You can inflict damage to your opponent equal to that opponent's monster's ATK. If this face-up card is destroyed by battle, or leaves the field because of an opponent's card effect while its owner controls it: You can Special Summon 1 \"Neos Wiseman\" from your hand or Deck, ignoring its Summoning conditions. You can only use this effect of \"Elemental HERO Neos Kluger\" once per turn."
        let cardId = "90307498"
        let cardAttribute = "Light"
        let monsterAssociation = MonsterAssociation(level: 10)
        
        CardStatsViewModel(cardName: cardName, monsterType: monsterType, cardEffect: cardEffect, monsterAssociation: monsterAssociation, cardId: cardId, cardAttribute: cardAttribute)
    }
}
