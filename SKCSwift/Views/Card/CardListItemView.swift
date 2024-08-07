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
        VStack(alignment: .leading) {
            Text(card.cardName)
                .fontWeight(.bold)
                .font(.subheadline)
                .lineLimit(1)
                .padding(.bottom, -5)
            
            HStack(alignment: .top) {
                CardImageView(length: 60, cardID: card.cardID, imgSize: .tiny, variant: .rounded_corner)
                    .equatable()
                    .padding(.trailing, 3)
                VStack(alignment: .leading) {
                    HStack {
                        CardColorIndicatorView(cardColor: card.cardColor)
                            .equatable()
                        AttributeView(attribute: Attribute(rawValue: card.cardAttribute) ?? .unknown)
                            .equatable()
                    }
                    
                    Text(card.monsterType ?? card.cardColor)
                        .fontWeight(.light)
                        .font(.callout)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity)
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
