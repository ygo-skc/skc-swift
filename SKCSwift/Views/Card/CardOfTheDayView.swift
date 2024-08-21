//
//  CardOfTheDayView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import SwiftUI

struct CardOfTheDayView: View, Equatable {
    let cardOfTheDay: CardOfTheDay?
    
    private static let IMAGE_SIZE: CGFloat = 90
    
    static func == (lhs: CardOfTheDayView, rhs: CardOfTheDayView) -> Bool {
        return lhs.cardOfTheDay == rhs.cardOfTheDay
    }
    
    var body: some View {
        NavigationLink(value: CardLinkDestinationValue(cardID: cardOfTheDay?.card.cardID ?? "", cardName: cardOfTheDay?.card.cardName ?? ""), label: {
            SectionView(
                header: "Card of the day",
                content: {
                    HStack(alignment: .top, spacing: 20) {
                        if let card = cardOfTheDay?.card {
                            CardImageView(length: CardOfTheDayView.IMAGE_SIZE, cardID: card.cardID, imgSize: .tiny, cardColor: card.cardColor)
                                .equatable()
                        } else {
                            PlaceholderView(width: CardOfTheDayView.IMAGE_SIZE, height: CardOfTheDayView.IMAGE_SIZE, radius: CardOfTheDayView.IMAGE_SIZE)
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            if let cardOfTheDay = cardOfTheDay {
                                InlineDateView(date: cardOfTheDay.date)
                                    .equatable()
                                Text(cardOfTheDay.card.cardName)
                                    .lineLimit(2)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Text(cardOfTheDay.card.cardType)
                                    .font(.headline)
                                    .lineLimit(1)
                            } else {
                                PlaceholderView(width: 200, height: 18, radius: 5)
                                PlaceholderView(width: 120, height: 18, radius: 5)
                                PlaceholderView(width: 60, height: 18, radius: 5)
                            }
                        }
                    }
                }
            )
            .contentShape(Rectangle())
        })
        .buttonStyle(.plain)
        .disabled(cardOfTheDay == nil)
    }
}

#Preview {
    CardOfTheDayView(cardOfTheDay: nil)
}

#Preview {
    CardOfTheDayView(cardOfTheDay: CardOfTheDay(date: "2024-03-12", version: 1,
                                                card: Card(cardID: "47172959", cardName: "Yubel - The Loving Defender Forever", cardColor: "Fusion", cardAttribute: "Dark", cardEffect: "", monsterType: "Fiend/Fusion/Effect")))
}
