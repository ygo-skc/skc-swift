//
//  CardStatsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import SwiftUI

struct CardStatsViewModel: View {
    var cardName: String
    var cardColor: String
    var monsterType: String?
    var cardEffect: String
    var monsterAssociation: MonsterAssociation?
    var cardId: String
    var cardAttribute: String
    var monsterAttack: String
    var monsterDefense: String
    
    var showAllInfo: Bool
    
    private static let nilStat = "?"
    
    init(
        cardName: String, cardColor: String, monsterType: String? = nil, cardEffect: String, monsterAssociation: MonsterAssociation? = nil,
        cardId: String, cardAttribute: String, monsterAttack: Int? = nil, monsterDefense: Int? = nil, showAllInfo: Bool = true
    ) {
        self.cardName = cardName
        self.cardColor = cardColor
        self.monsterType = monsterType
        self.cardEffect = cardEffect
        self.monsterAssociation = monsterAssociation
        self.cardId = cardId
        self.cardAttribute = cardAttribute
        
        self.showAllInfo = showAllInfo
        
        let nilDefStat = (cardColor == "Link") ? "—" : CardStatsViewModel.nilStat  // override missing stat for certain edge cases
        self.monsterAttack = (monsterAttack == nil) ? CardStatsViewModel.nilStat : String(monsterAttack!)
        self.monsterDefense = (monsterDefense == nil) ? nilDefStat : String(monsterDefense!)
    }
    
    var body: some View {
        VStack {
            VStack  {
                Text(cardName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .bold()
                    .lineLimit(1)
                
                let attribute = Attribute(rawValue: cardAttribute)
                if (monsterAssociation != nil && attribute != nil){
                    MonsterAssociationViewModel(monsterAssociation: monsterAssociation!, attribute: attribute!)
                        .padding(.top, -8.0)
                }
                
                
                VStack(alignment: .leading) {
                    if (monsterType != nil) {
                        Text(monsterType!)
                            .font(.headline)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                            .bold()
                            .padding(.bottom, 1.0)
                    }
                    
                    Text(replaceHTMLEntities(subject: cardEffect))
                        .modifier(CardEffectModifier(variant: (showAllInfo) ? .fullText : .shortened))
                    
                    HStack {
                        Text(cardId)
                            .font(.callout)
                            .fontWeight(.light)
                        
                        Spacer()
                        
                        if (cardColor != "Spell" && cardColor != "Trap") {
                            HStack {
                                Text(monsterAttack)
                                    .padding(.horizontal, 4.0)
                                    .padding(.vertical, 2.0)
                                    .foregroundColor(.red)
                                    .fontWeight(.bold)
                                Text(monsterDefense)
                                    .padding(.horizontal, 4.0)
                                    .padding(.vertical, 2.0)
                                    .foregroundColor(.blue)
                                    .fontWeight(.bold)
                            }
                            .background(Color("translucent_background"))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.top, 1)
                }
                .padding(.all, 8)
                .background(Color("translucent_background"))
                .cornerRadius(10)
            }.padding(.horizontal, 5.0)
                .padding(.vertical, 10.0)
        }.background(cardColorUI(cardColor: cardColor))
            .cornerRadius(15)
            .frame(
                maxWidth: .infinity,
                alignment: .topLeading
            )
    }
}

private struct CardEffectModifier: ViewModifier {
    enum CardEffectVariant {
        case fullText
        case shortened
    }
    
    var variant: CardEffectVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .fullText:
            content
                .font(.body)
                .fontWeight(.light)
                .multilineTextAlignment(.leading)
                .bold()
                .frame(maxWidth: .infinity, alignment: .topLeading)
        case .shortened:
            content
                .fontWeight(.light)
                .multilineTextAlignment(.leading)
                .bold()
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .lineLimit(3)
        }
    }
}

struct CardStatsViewModel_Previews: PreviewProvider {
    static var previews: some View {
        CardStatsViewModel(
            cardName: "Elemental HERO Neos Kluger",
            cardColor: "Fusion",
            monsterType: "Spellcaster/Fusion/Effect",
            cardEffect: "\"Elemental HERO Neos\" + \"Yubel\"\nMust be Fusion Summoned. Before damage calculation, if this card battles an opponent's monster: You can inflict damage to your opponent equal to that opponent's monster's ATK. If this face-up card is destroyed by battle, or leaves the field because of an opponent's card effect while its owner controls it: You can Special Summon 1 \"Neos Wiseman\" from your hand or Deck, ignoring its Summoning conditions. You can only use this effect of \"Elemental HERO Neos Kluger\" once per turn.",
            monsterAssociation: MonsterAssociation(level: 10),
            cardId: "90307498",
            cardAttribute: "Light",
            monsterAttack: 3000,
            monsterDefense: 2500
        )
        
        CardStatsViewModel(
            cardName: "Elemental HERO Neos Kluger",
            cardColor: "Fusion",
            monsterType: "Spellcaster/Fusion/Effect",
            cardEffect: "\"Elemental HERO Neos\" + \"Yubel\"\nMust be Fusion Summoned. Before damage calculation, if this card battles an opponent's monster: You can inflict damage to your opponent equal to that opponent's monster's ATK. If this face-up card is destroyed by battle, or leaves the field because of an opponent's card effect while its owner controls it: You can Special Summon 1 \"Neos Wiseman\" from your hand or Deck, ignoring its Summoning conditions. You can only use this effect of \"Elemental HERO Neos Kluger\" once per turn.",
            monsterAssociation: MonsterAssociation(level: 10),
            cardId: "90307498",
            cardAttribute: "Light",
            monsterAttack: 3000,
            monsterDefense: 2500,
            showAllInfo: false
        )
        .previewDisplayName("Don't show all info")
    }
}
