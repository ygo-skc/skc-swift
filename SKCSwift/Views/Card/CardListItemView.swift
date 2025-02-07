//
//  SwiftUIView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/21/24.
//

import SwiftUI


struct CardListItemView: View, Equatable {
    let card: Card
    let showAllInfo: Bool
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 15) {
            CardImageView(length: 60, cardID: card.cardID, imgSize: .tiny, variant: .roundedCorner)
                .equatable()
                .padding(.trailing, 3)
            VStack(alignment: .leading) {
                Text(card.cardName)
                    .fontWeight(.bold)
                    .font(.subheadline)
                    .lineLimit(1)
                
                HStack {
                    Text(card.monsterType ?? card.cardColor)
                        .font(.caption)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    Text(card.cardID)
                        .font(.caption)
                        .fontWeight(.light)
                }
                
                HStack {
                    CardColorIndicatorView(cardColor: card.cardColor, variant: .regular)
                        .equatable()
                    if showAllInfo {
                        MonsterAssociationView(monsterAssociation: card.monsterAssociation,
                                               attribute: card.attribute,
                                               variant: .listView,
                                               iconVariant: .regular)
                        .equatable()
                    } else {
                        AttributeView(attribute: card.attribute, variant: .regular)
                            .equatable()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .dynamicTypeSize(...DynamicTypeSize.medium)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

extension CardListItemView {
    init(card: Card) {
        self.init(card: card, showAllInfo: false)
    }
}

#Preview("Card Search Result") {
    CardListItemView(card: Card(
        cardID: "40044918",
        cardName: "Elemental HERO Stratos",
        cardColor: "Effect",
        cardAttribute: "Wind",
        cardEffect: "Draw 2",
        monsterType: "Warrior/Effect"
    ))
}

#Preview("Card Search Result - IMG DNE") {
    CardListItemView(card: Card(
        cardID: "40044918",
        cardName: "Elemental HERO Stratos",
        cardColor: "Effect",
        cardAttribute: "Wind",
        cardEffect: "Draw 2",
        monsterType: "Warrior/Effect"
    ))
}
