//
//  YGOCardView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 5/2/23.
//

import SwiftUI

struct YGOCardView: View, Equatable {
    let cardID: String
    let card: YGOCard?
    let variant: YGOCardViewVariant
    
    private let width: CGFloat
    private let imageSize: CGFloat
    private let imageSizeVariant: ImageSize
    
    init(cardID: String, card: YGOCard?, width: CGFloat = 220, variant: YGOCardViewVariant = .normal) {
        self.cardID = cardID
        self.card = card
        self.variant = variant
        
        self.width = width
        self.imageSize = (variant == .normal) ? width - 80 : width - 30
        self.imageSizeVariant = (variant == .normal) ? .medium : .extraSmall
    }
    
    var body: some View {
        VStack(spacing: 5) {
            CardImageView(length: imageSize, cardID: cardID, imgSize: imageSizeVariant, variant: .roundedCorner)
                .equatable()
            
            CardStatsView(card: card, variant: variant)
                .equatable()
        }
        .frame(width: width)
    }
}

#Preview {
    YGOCardView(
        cardID: "40044918",
        card: YGOCard(
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
        card: YGOCard(
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
