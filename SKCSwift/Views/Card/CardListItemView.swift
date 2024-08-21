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
        VStack(alignment: .leading) {
            HStack() {
                CardColorIndicatorView(cardColor: card.cardColor)
                    .equatable()
                Text(card.cardName)
                    .fontWeight(.bold)
                    .font(.headline)
                    .lineLimit(1)
                    .padding(.bottom, -3)
            }
            HStack(alignment: .top, spacing: 15) {
                CardImageView(length: 55, cardID: card.cardID, imgSize: .tiny, variant: .roundedCorner)
                    .equatable()
                    .padding(.trailing, 3)
                VStack(alignment: .leading) {
                    if showAllInfo {
                        MonsterAssociationView(monsterAssociation: card.monsterAssociation, 
                                               attribute: card.attribute,
                                               variant: .listView)
                            .equatable()
                    } else {
                        AttributeView(attribute: card.attribute)
                            .equatable()
                    }
                    
                    Text(card.monsterType ?? card.cardColor)
                        .font(.subheadline)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity)
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
