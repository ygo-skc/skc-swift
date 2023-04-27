//
//  CardOfTheDayView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import SwiftUI

struct CardOfTheDayView: View {
    @StateObject private var cardOfTheDay = CardOfTheDayViewModel()
    
    var body: some View {
        SectionView(
            header: "Card of the day",
            disableDestination: false,
            destination: {CardSearchLinkDestination(cardId: cardOfTheDay.card.cardID)},
            content: {CardOfTheDayContentView(cardId: cardOfTheDay.card.cardID, cardName: cardOfTheDay.card.cardName, cardColor: cardOfTheDay.card.cardColor)}
        )
        .onAppear{
            cardOfTheDay.fetchData()
        }
    }
}

private struct CardOfTheDayContentView: View {
    var cardId: String
    var cardName: String
    var monsterType: String?
    var cardColor: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(cardName)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                if (monsterType != nil) {
                    Text(monsterType!)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Circle()
                        .foregroundColor(cardColorUI(cardColor: cardColor))
                        .frame(width: 15)
                    Text(cardColor)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .padding(.top, -10)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .topLeading
            )
            RoundedImageView(radius: 90, imageUrl: URL(string: "https://images.thesupremekingscastle.com/cards/sm/\(cardId).jpg")!)
        }
        .contentShape(Rectangle())
    }
}

struct CardOfTheDayView_Previews: PreviewProvider {
    static var previews: some View {
        CardOfTheDayView()
    }
}
