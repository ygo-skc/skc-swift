//
//  SwiftUIView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/21/24.
//

import SwiftUI


struct CardListItemView: View {
    var cardID: String
    var cardName: String
    var monsterType: String?
    
    var body: some View {
        HStack(alignment: .top) {
            YGOCardImage(height: 60, imgSize: .tiny, cardID: cardID)
            VStack(alignment: .leading) {
                Text(cardName)
                    .fontWeight(.bold)
                    .font(.subheadline)
                    .lineLimit(2)
                if let monsterType {
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
    CardListItemView(cardID: "40044918", cardName: "Elemental HERO Stratos", monsterType: "Warrior/Effect")
}

#Preview("Card Search Result - IMG DNE") {
    CardListItemView(cardID: "08949584", cardName: "A HERO Lives")
}
