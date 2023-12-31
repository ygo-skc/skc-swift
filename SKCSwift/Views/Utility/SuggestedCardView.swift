//
//  CardSuggestionViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/24/23.
//

import SwiftUI

struct SuggestedCardView: View {
    var card: Card
    var occurrence: Int
    
    var body: some View {
        NavigationLink(value: CardValue(cardID: card.cardID), label: {
            VStack {
                HStack(spacing: 20) {
                    YGOCardImage(height: 90.0, imgSize: .tiny, cardID: card.cardID, variant: .round)
                    
                    Text("\(occurrence) Reference(s)")
                        .font(.subheadline)
                }
                
                CardStatsView(card: card, variant: .condensed)
            }
            .contentShape(Rectangle())
            .frame(width: 220)
        })
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {    
    SuggestedCardView(
        card: Card(
            cardID: "40044918",
            cardName: "Elemental HERO Stratos",
            cardColor: "Effect",
            cardAttribute: "Wind",
            cardEffect: "Draw 2",
            monsterType: "Warrior/Effect"
        ), occurrence: 1)
}
