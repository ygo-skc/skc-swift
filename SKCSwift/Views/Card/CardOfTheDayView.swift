//
//  CardOfTheDayView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import SwiftUI

struct CardOfTheDayView: View {
    @Bindable var model: HomeViewModel
    
    private static let IMAGE_SIZE: CGFloat = 90
    
    var body: some View {
        NavigationLink(value: CardLinkDestinationValue(cardID: model.cardOfTheDay?.card.cardID ?? "", cardName: model.cardOfTheDay?.card.cardName ?? ""), label: {
            SectionView(
                header: "Card of the day",
                content: {
                    if let networkError = model.requestErrors["cardOfTheDay", default: nil] {
                        NetworkErrorView(error: networkError, action: { Task { await model.fetchCardOfTheDayData() } })
                    } else {
                        HStack(alignment: .top, spacing: 20) {
                            if let card = model.cardOfTheDay?.card {
                                CardImageView(length: CardOfTheDayView.IMAGE_SIZE, cardID: card.cardID, imgSize: .tiny, cardColor: card.cardColor)
                                    .equatable()
                            } else {
                                PlaceholderView(width: CardOfTheDayView.IMAGE_SIZE, height: CardOfTheDayView.IMAGE_SIZE, radius: CardOfTheDayView.IMAGE_SIZE)
                            }
                            VStack(alignment: .leading, spacing: 5) {
                                if let cardOfTheDay = model.cardOfTheDay {
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
                }
            )
            .contentShape(Rectangle())
        })
        .buttonStyle(.plain)
        .disabled(model.cardOfTheDay == nil)
    }
}

#Preview {
    let model = HomeViewModel()
    CardOfTheDayView(model: model)
}

#Preview {
    let model = HomeViewModel()
    CardOfTheDayView(model: model)
        .task {
            await model.fetchCardOfTheDayData()
        }
}
