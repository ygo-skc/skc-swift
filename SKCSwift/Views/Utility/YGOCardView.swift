//
//  YGOCardView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 5/2/23.
//

import SwiftUI

struct YGOCardView: View {
    var card: Card
    var isDataLoaded: Bool
    
    private let imageSize = UIScreen.main.bounds.width - 60
    private let imageUrl: URL
    
    init(card: Card, isDataLoaded: Bool) {
        self.card = card
        self.isDataLoaded = isDataLoaded
        
        self.imageUrl =  URL(string: "https://images.thesupremekingscastle.com/cards/lg/\(card.cardID).jpg")!
    }
    
    var body: some View {
        VStack(spacing: 5) {
            RoundedRectImage(width: imageSize, height: imageSize, imageUrl: imageUrl)
            
            if (isDataLoaded) {
                CardStatsView(card: card)
            } else {
                PlaceholderView(width: UIScreen.main.bounds.width, height: 250, radius: 10)
            }
        }
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
