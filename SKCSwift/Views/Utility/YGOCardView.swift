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
    private let imageUrl: URL
    
    init(card: Card, isDataLoaded: Bool, variant: YGOCardViewVariant = .normal) {
        self.card = card
        self.isDataLoaded = isDataLoaded
        self.variant = variant
        
        self.width = (variant == .normal) ?  UIScreen.main.bounds.width : 250
        self.imageSize = (variant == .normal) ? width - 60 : width - 30
        self.imageUrl = (variant == .normal) ? URL(string: "https://images.thesupremekingscastle.com/cards/lg/\(card.cardID).jpg")! : URL(string: "https://images.thesupremekingscastle.com/cards/x-sm/\(card.cardID).jpg")!
    }
    
    var body: some View {
        VStack(spacing: 5) {
            RoundedRectImage(width: imageSize, height: imageSize, imageUrl: imageUrl)
            
            if (isDataLoaded) {
                CardStatsView(card: card, variant: variant)
            } else {
                PlaceholderView(width: width, height: 250, radius: 10)
            }
        }
        .frame(width: width)
    }
}

struct YGOCardView_Previews: PreviewProvider {
    static var previews: some View {
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
}
