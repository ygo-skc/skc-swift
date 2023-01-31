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
    
    var variant: CardStatsVariant
    
    private static let nilStat = "?"
    
    init(
        cardName: String, cardColor: String, monsterType: String? = nil, cardEffect: String, monsterAssociation: MonsterAssociation? = nil,
        cardId: String, cardAttribute: String, monsterAttack: Int? = nil, monsterDefense: Int? = nil, variant: CardStatsVariant = .full
    ) {
        self.cardName = cardName
        self.cardColor = cardColor
        self.monsterType = monsterType
        self.cardEffect = cardEffect
        self.monsterAssociation = monsterAssociation
        self.cardId = cardId
        self.cardAttribute = cardAttribute
        
        self.variant = variant
        
        let nilDefStat = (cardColor == "Link") ? "—" : CardStatsViewModel.nilStat  // override missing stat for certain edge cases
        self.monsterAttack = (monsterAttack == nil) ? CardStatsViewModel.nilStat : String(monsterAttack!)
        self.monsterDefense = (monsterDefense == nil) ? nilDefStat : String(monsterDefense!)
    }
    
    var body: some View {
        VStack {
            VStack  {
                Text(cardName)
                    .modifier(CardNameModifier(variant: variant))
                    .foregroundColor(.white)
                
                let attribute = Attribute(rawValue: cardAttribute)
                if (monsterAssociation != nil && attribute != nil){
                    MonsterAssociationViewModel(monsterAssociation: monsterAssociation!, attribute: attribute!)
                        .padding(.top, -8.0)
                }
                
                
                VStack(alignment: .leading) {
                    if (monsterType != nil) {
                        Text(monsterType!)
                            .modifier(MonsterTypeModifier(variant: variant))
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 1.0)
                    }
                    
                    Text(replaceHTMLEntities(subject: cardEffect))
                        .modifier(CardEffectModifier(variant: variant))
                        .fontWeight(.light)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    HStack {
                        Text(cardId)
                            .modifier(CardIdModifier(variant: variant))
                            .fontWeight(.light)
                        
                        Spacer()
                        
                        if (cardColor != "Spell" && cardColor != "Trap") {
                            HStack {
                                Text(monsterAttack)
                                    .modifier(MonsterAttackDefenseModifier(variant: variant))
                                    .fontWeight(.bold)
                                    .padding(.leading, 10)
                                    .padding(.vertical, 2.0)
                                    .foregroundColor(.red)
                                Text(monsterDefense)
                                    .modifier(MonsterAttackDefenseModifier(variant: variant))
                                    .fontWeight(.bold)
                                    .padding(.trailing, 10)
                                    .padding(.vertical, 2.0)
                                    .foregroundColor(.blue)
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

enum CardStatsVariant {
    case full
    case condensed
}

private struct CardNameModifier: ViewModifier {
    var variant: CardStatsVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .full:
            content
                .font(.title3)
                .fontWeight(.semibold)
                .lineLimit(1)
        case .condensed:
            content
                .font(.headline)
                .fontWeight(.medium)
                .lineLimit(1)
        }
    }
}

private struct MonsterTypeModifier: ViewModifier {
    var variant: CardStatsVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .full:
            content
                .font(.headline)
        case .condensed:
            content
                .font(.subheadline)
        }
    }
}

private struct CardEffectModifier: ViewModifier {
    var variant: CardStatsVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .full:
            content
                .font(.body)
        case .condensed:
            content
                .font(.callout)
                .lineLimit(3)
        }
    }
}

private struct CardIdModifier: ViewModifier {
    var variant: CardStatsVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .full:
            content
                .font(.callout)
        case .condensed:
            content
                .font(.footnote)
        }
    }
}

private struct MonsterAttackDefenseModifier: ViewModifier {
    var variant: CardStatsVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .full:
            content
                .font(.callout)
        case .condensed:
            content
                .font(.footnote)
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
            variant: .condensed
        )
        .previewDisplayName("Don't show all info")
    }
}
