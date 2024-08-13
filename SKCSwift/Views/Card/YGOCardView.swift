//
//  YGOCardView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 5/2/23.
//

import SwiftUI

struct YGOCardView: View, Equatable {
    let cardID: String
    let card: Card?
    let variant: YGOCardViewVariant
    
    private let width: CGFloat
    private let imageSize: CGFloat
    private let imageSizeVariant: ImageSize
    
    init(cardID: String, card: Card?, variant: YGOCardViewVariant = .normal) {
        self.cardID = cardID
        self.card = card
        self.variant = variant
        
        self.width = (variant == .normal) ?  UIScreen.main.bounds.width : 220
        self.imageSize = (variant == .normal) ? width - 60 : width - 20
        self.imageSizeVariant = (variant == .normal) ? .medium : .extra_small
    }
    
    var body: some View {
        VStack(spacing: 5) {
            CardImageView(length: imageSize, cardID: cardID, imgSize: imageSizeVariant, variant: .roundedCorner)
                .equatable()
            
            if let card {
                CardStatsView(card: card, variant: variant)
                    .equatable()
            } else {
                PlaceholderView(width: width, height: 250, radius: 10)
            }
        }
        .frame(width: width)
    }
}

#Preview {
    YGOCardView(
        cardID: "40044918",
        card: Card(
            cardID: "40044918",
            cardName: "Elemental HERO Stratos",
            cardColor: "Effect",
            cardAttribute: "Wind",
            cardEffect: "Draw 2",
            monsterType: "Warrior/Effect"
        )
    )
}

#Preview("Condensed") {
    YGOCardView(
        cardID: "40044918",
        card: Card(
            cardID: "40044918",
            cardName: "Elemental HERO Stratos",
            cardColor: "Effect",
            cardAttribute: "Wind",
            cardEffect: "Draw 2",
            monsterType: "Warrior/Effect"
        ),
        variant: .condensed
    )
}
