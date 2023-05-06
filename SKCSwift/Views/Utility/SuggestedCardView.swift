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
        NavigationLink(destination: CardSearchLinkDestination(cardID: card.cardID), label: {
            VStack {
                HStack(spacing: 20) {
                    RoundedImageView(radius: 100, imageUrl: URL(string: "https://images.thesupremekingscastle.com/cards/lg/\(card.cardID).jpg")!)
                    
                    Text("\(occurrence) Reference(s)")
                        .font(.headline)
                        .fontWeight(.regular)
                }
                
                CardStatsView(card: card, variant: .condensed)
            }
            .contentShape(Rectangle())
            .frame(width: 250)
        })
        .buttonStyle(PlainButtonStyle())
    }
}

struct SuggestedCardViewModel_Preview: PreviewProvider {
    static var previews: some View {
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
}
