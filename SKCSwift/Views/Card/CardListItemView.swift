//
//  SwiftUIView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/21/24.
//

import SwiftUI


struct CardListItemView: View, Equatable {
    let card: Card
    
    var body: some View {
        HStack(alignment: .top) {
            CardImageView(length: 65, cardID: card.cardID, imgSize: .tiny, cardColor: card.cardColor)
                .equatable()
            AttributeView(attribute: Attribute(rawValue: card.cardAttribute) ?? .unknown)
            VStack(alignment: .leading) {
                Text(card.cardName)
                    .fontWeight(.bold)
                    .font(.subheadline)
                    .lineLimit(2)
                if let monsterType = card.monsterType {
                    Text(monsterType)
                        .fontWeight(.light)
                        .font(.callout)
                        .lineLimit(2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
