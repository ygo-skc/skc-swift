//
//  YGOCardView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 5/2/23.
//

import SwiftUI

struct YGOCardView: View {
    let card: Card
    let isDataLoaded: Bool
    let variant: YGOCardViewVariant
    
    private let width: CGFloat
    private let imageSize: CGFloat
    private let imageSizeVariant: ImageSize
    
    init(card: Card, isDataLoaded: Bool, variant: YGOCardViewVariant = .normal) {
        self.card = card
        self.isDataLoaded = isDataLoaded
        self.variant = variant
        
        self.width = (variant == .normal) ?  UIScreen.main.bounds.width : 220
        self.imageSize = (variant == .normal) ? width - 60 : width
        self.imageSizeVariant = (variant == .normal) ? .medium : .extra_small
    }
    
    var body: some View {
        VStack(spacing: 5) {
            YGOCardImage(height: imageSize, imgSize: imageSizeVariant, cardID: card.cardID, variant: .rounded_corner)
            
            if (isDataLoaded) {
                CardStatsView(card: card, variant: variant)
            } else {
                PlaceholderView(width: width, height: 250, radius: 10)
            }
        }
        .frame(width: width)
    }
}

#Preview {
    YGOCardView(
        card: Card(
            cardID: "40044918",
            cardName: "Elemental HERO Stratos",
            cardColor: "Effect",
            cardAttribute: "Wind",
            cardEffect: "Draw 2",
            monsterType: "Warrior/Effect"
        ), isDataLoaded: true
    )
}

#Preview("Condensed") {
    YGOCardView(
        card: Card(
            cardID: "40044918",
            cardName: "Elemental HERO Stratos",
            cardColor: "Effect",
            cardAttribute: "Wind",
            cardEffect: "Draw 2",
            monsterType: "Warrior/Effect"
        ), isDataLoaded: true,
        variant: .condensed
    )
}
