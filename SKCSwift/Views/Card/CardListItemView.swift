//
//  SwiftUIView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/21/24.
//

import SwiftUI


struct CardListItemView: View, Equatable {
    let cardID: String
    let cardName: String
    let monsterType: String?
    
    var body: some View {
        HStack(alignment: .top) {
            CardImage(length: 60, cardID: cardID, imgSize: .tiny)
                .equatable()
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

extension CardListItemView {
    init(cardID: String, cardName: String) {
        self.init(cardID: cardID, cardName: cardName, monsterType: nil)
    }
}

#Preview("Card Search Result") {
    CardListItemView(cardID: "40044918", cardName: "Elemental HERO Stratos", monsterType: "Warrior/Effect")
}

#Preview("Card Search Result - IMG DNE") {
    CardListItemView(cardID: "08949584", cardName: "A HERO Lives")
}
