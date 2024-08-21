//
//  CardStatsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import SwiftUI

struct CardStatsView: View, Equatable {
    let card: Card
    let variant: YGOCardViewVariant
    
    private let attribute: Attribute
    
    init(card: Card, variant: YGOCardViewVariant = .normal) {
        self.card = card
        self.variant = variant
        
        self.attribute = card.attribute
    }
    
    var body: some View {
        VStack(spacing: 5)  {
            Text(card.cardName)
                .modifier(CardNameModifier(variant: variant))
                .foregroundColor(.white)
            
            if variant != .condensed {
                MonsterAssociationView(monsterAssociation: card.monsterAssociation, attribute: attribute)
                    .equatable()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(card.cardType)
                    .modifier(MonsterTypeModifier(variant: variant))
                
                Text(replaceHTMLEntities(subject: card.cardEffect))
                    .modifier(CardEffectModifier(variant: variant))
                
                HStack {
                    Text(card.cardID)
                        .modifier(CardIdModifier(variant: variant))
                    
                    Spacer()
                    
                    HStack(spacing: 15) {
                        Text(card.atk)
                            .modifier(MonsterAttackDefenseModifier(variant: variant))
                            .foregroundColor(.red)
                        Text(card.def)
                            .modifier(MonsterAttackDefenseModifier(variant: variant))
                            .foregroundColor(.blue)
                    }
                    .modifier(MonsterAttackDefenseContainerModifier(variant: variant))
                    .if(card.cardColor == "Spell" || card.cardColor == "Trap" ) {
                        $0.hidden()
                    }
                }
                .padding(.top, 1)
            }
            .padding(.all, (variant == .normal) ? 10 : 6)
            .background(.regularMaterial)
            .cornerRadius((variant == .normal) ? 10 : 7)
        }
        .padding(.all, (variant == .normal) ? 8 : 5)
        .if(card.isPendulum) {
            $0.background(cardColorGradient(cardColor: card.cardColor))
        } else: {
            $0.background(cardColorUI(cardColor: card.cardColor))
        }
        .cornerRadius((variant == .normal) ? 10 : 7)
        .frame(
            maxWidth: .infinity,
            alignment: .topLeading
        )
        .dynamicTypeSize(...DynamicTypeSize.xLarge)
    }
}

private struct CardNameModifier: ViewModifier {
    var variant: YGOCardViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal:
            content
                .font(.title3)
                .fontWeight(.semibold)
                .lineLimit(1)
        case .condensed, .listView:
            content
                .font(.headline)
                .lineLimit(1)
                .padding(.vertical, -1)
        }
    }
}

private struct MonsterTypeModifier: ViewModifier {
    var variant: YGOCardViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal:
            content
                .font(.body)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 1.0)
        case .condensed, .listView:
            content
                .font(.footnote)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 1.0)
        }
    }
}

private struct CardEffectModifier: ViewModifier {
    var variant: YGOCardViewVariant
    
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
                .font(.footnote)
                .fontWeight(.light)
                .lineLimit(3, reservesSpace: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        case .listView:
            content
                .font(.footnote)
                .fontWeight(.light)
                .lineLimit(3, reservesSpace: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}

private struct CardIdModifier: ViewModifier {
    var variant: YGOCardViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal:
            content
                .font(.callout)
                .fontWeight(.light)
        case .condensed, .listView:
            content
                .font(.caption)
                .fontWeight(.light)
        }
    }
}

private struct MonsterAttackDefenseModifier: ViewModifier {
    var variant: YGOCardViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal:
            content
                .font(.callout)
                .fontWeight(.bold)
        case .condensed, .listView:
            content
                .font(.caption)
                .fontWeight(.bold)
        }
    }
}

private struct MonsterAttackDefenseContainerModifier: ViewModifier {
    var variant: YGOCardViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal:
            content
                .padding(.all, 5)
                .background(.thickMaterial)
                .cornerRadius(10)
        case .condensed, .listView:
            content
                .padding(.all, 4)
                .background(.thickMaterial)
                .cornerRadius(8)
        }
    }
}

#Preview("Card Stats - Default") {
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
}

#Preview("Card Stats - Condensed") {
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
}
