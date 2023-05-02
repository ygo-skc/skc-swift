//
//  CardStatsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import SwiftUI

struct CardStatsView: View {
    var cardName: String
    var cardColor: String
    var monsterType: String?
    var cardEffect: String
    var monsterAssociation: MonsterAssociation?
    var cardId: String
    var cardAttribute: String
    var monsterAttack: String
    var monsterDefense: String
    
    var variant: CardStatsViewVariant
    
    private var attribute: Attribute?
    private static let nilStat = "?"
    
    init(card: Card, variant: CardStatsViewVariant = .normal) {
        self.cardName = card.cardName
        self.cardColor = card.cardColor
        self.monsterType = card.monsterType
        self.cardEffect = card.cardEffect
        self.monsterAssociation = card.monsterAssociation
        self.cardId = card.cardID
        self.cardAttribute = card.cardAttribute
        
        self.variant = variant
        
        let nilDefStat = (cardColor == "Link") ? "—" : CardStatsView.nilStat  // override missing stat for certain edge cases
        self.monsterAttack = (card.monsterAttack == nil) ? CardStatsView.nilStat : String(card.monsterAttack!)
        self.monsterDefense = (card.monsterDefense == nil) ? nilDefStat : String(card.monsterDefense!)
        
        self.attribute = Attribute(rawValue: cardAttribute)
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 5)  {
                Text(cardName)
                    .modifier(CardNameModifier(variant: variant))
                    .foregroundColor(.white)
                
                if (monsterAssociation != nil && attribute != nil) {
                    MonsterAssociationView(monsterAssociation: monsterAssociation!, attribute: attribute!)
                }
                
                
                VStack(alignment: .leading, spacing: 5) {
                    Text((monsterType != nil) ? monsterType! : "Spell")
                        .modifier(MonsterTypeModifier(variant: variant))
                    
                    Text(replaceHTMLEntities(subject: cardEffect))
                        .modifier(CardEffectModifier(variant: variant))
                    
                    HStack {
                        Text(cardId)
                            .modifier(CardIdModifier(variant: variant))
                            .fontWeight(.light)
                        
                        Spacer()
                        HStack(spacing: 15) {
                            Text(monsterAttack)
                                .modifier(MonsterAttackDefenseModifier(variant: variant))
                                .foregroundColor(.red)
                            Text(monsterDefense)
                                .modifier(MonsterAttackDefenseModifier(variant: variant))
                                .foregroundColor(.blue)
                        }
                        .modifier(MonsterAttackDefenseContainerModifier(cardType: (cardColor == "Spell" || cardColor == "Trap") ? .non_monster : .monster))
                        
                    }
                    .padding(.top, 1)
                }
                .padding(.all, 8)
                .background(Color("translucent_background"))
                .cornerRadius(10)
            }
            .padding(.horizontal, 5.0)
            .padding(.vertical, 10.0)
        }
        .background(cardColorUI(cardColor: cardColor))
        .cornerRadius(15)
        .frame(
            maxWidth: .infinity,
            alignment: .topLeading
        )
    }
}

private struct CardNameModifier: ViewModifier {
    var variant: CardStatsViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal:
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
    var variant: CardStatsViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal:
            content
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 1.0)
        case .condensed:
            content
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 1.0)
        }
    }
}

private struct CardEffectModifier: ViewModifier {
    var variant: CardStatsViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal:
            content
                .font(.body)
                .fontWeight(.light)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        case .condensed:
            content
                .font(.callout)
                .lineLimit(3, reservesSpace: true)
                .fontWeight(.light)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}

private struct CardIdModifier: ViewModifier {
    var variant: CardStatsViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal:
            content
                .font(.callout)
        case .condensed:
            content
                .font(.footnote)
        }
    }
}

private struct MonsterAttackDefenseModifier: ViewModifier {
    var variant: CardStatsViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal:
            content
                .font(.callout)
                .fontWeight(.bold)
        case .condensed:
            content
                .font(.footnote)
                .fontWeight(.bold)
        }
    }
}

private struct MonsterAttackDefenseContainerModifier: ViewModifier {
    var cardType: CardType
    
    func body(content: Content) -> some View {
        switch(cardType) {
        case .monster:
            content
                .padding(.all, 5)
                .background(Color("translucent_background"))
                .cornerRadius(20)
        case .non_monster:
            content
                .padding(.all, 5)
                .background(Color("translucent_background"))
                .cornerRadius(20)
                .hidden()
        }
    }
}

struct CardStatsView_Previews: PreviewProvider {
    static var previews: some View {
        CardStatsView(
            card: Card(
                cardID: "90307498",
                cardName: "Elemental HERO Neos Kluger",
                cardColor: "Fusion",
                cardAttribute: "Light",
                cardEffect: "\"Elemental HERO Neos\" + \"Yubel\"\nMust be Fusion Summoned. Before damage calculation, if this card battles an opponent's monster: You can inflict damage to your opponent equal to that opponent's monster's ATK. If this face-up card is destroyed by battle, or leaves the field because of an opponent's card effect while its owner controls it: You can Special Summon 1 \"Neos Wiseman\" from your hand or Deck, ignoring its Summoning conditions. You can only use this effect of \"Elemental HERO Neos Kluger\" once per turn.",
                monsterType: "Spellcaster/Fusion/Effect",
                monsterAssociation: MonsterAssociation(level: 10),
                monsterAttack: 3000,
                monsterDefense: 2500
            )
        )
        
        CardStatsView(
            card: Card(
                cardID: "90307498",
                cardName: "Elemental HERO Neos Kluger",
                cardColor: "Fusion",
                cardAttribute: "Light",
                cardEffect: "\"Elemental HERO Neos\" + \"Yubel\"\nMust be Fusion Summoned. Before damage calculation, if this card battles an opponent's monster: You can inflict damage to your opponent equal to that opponent's monster's ATK. If this face-up card is destroyed by battle, or leaves the field because of an opponent's card effect while its owner controls it: You can Special Summon 1 \"Neos Wiseman\" from your hand or Deck, ignoring its Summoning conditions. You can only use this effect of \"Elemental HERO Neos Kluger\" once per turn.",
                monsterType: "Spellcaster/Fusion/Effect",
                monsterAssociation: MonsterAssociation(level: 10),
                monsterAttack: 3000,
                monsterDefense: 2500
            ), variant: .condensed
        )
        .previewDisplayName("Don't show all info")
    }
}
