//
//  CardOfTheDayView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import SwiftUI

struct CardOfTheDayView: View, Equatable {
    nonisolated static func == (lhs: CardOfTheDayView, rhs: CardOfTheDayView) -> Bool {
        lhs.cotd == rhs.cotd && lhs.isDataLoaded == rhs.isDataLoaded && lhs.networkError == rhs.networkError
    }
    
    let cotd: CardOfTheDay
    let isDataLoaded: Bool
    let networkError: NetworkError?
    let retryCB: () async -> Void
    
    private static let IMAGE_SIZE: CGFloat = 90
    
    var body: some View {
        NavigationLink(value: CardLinkDestinationValue(cardID: cotd.card.cardID, cardName: cotd.card.cardName), label: {
            SectionView(
                header: "Card of the day",
                content: {
                    HStack(alignment: .top, spacing: 20) {
                        if let networkError {
                            NetworkErrorView(error: networkError, action: { Task { await retryCB() } })
                        } else {
                            if isDataLoaded || cotd.card.cardID != "" {
                                CardImageView(length: CardOfTheDayView.IMAGE_SIZE, cardID: cotd.card.cardID, imgSize: .tiny, cardColor: cotd.card.cardColor)
                                    .equatable()
                            } else {
                                PlaceholderView(width: CardOfTheDayView.IMAGE_SIZE, height: CardOfTheDayView.IMAGE_SIZE, radius: CardOfTheDayView.IMAGE_SIZE)
                            }
                            VStack(alignment: .leading, spacing: 5) {
                                if isDataLoaded ||  cotd.card.cardID != "" {
                                    InlineDateView(date: cotd.date)
                                        .equatable()
                                    Text(cotd.card.cardName)
                                        .lineLimit(2)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    Text(cotd.card.cardType)
                                        .font(.headline)
                                        .foregroundColor(.secondary)
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
        .disabled(!isDataLoaded && networkError == nil)
    }
}

#Preview("Default") {
    NavigationStack {
        CardOfTheDayView(cotd: CardOfTheDay(date: "2025-02-24", version: 1,
                                            card: Card(cardID: "68762510", cardName: "Lucky Pied Piper", cardColor: "Effect", cardAttribute: "Wind" , cardEffect: "")),
                         isDataLoaded: true, networkError: nil, retryCB: {})
        .padding(.horizontal)
    }
}

#Preview("Loading") {
    NavigationStack {
        CardOfTheDayView(cotd: CardOfTheDay(date: "2025-02-24", version: 1,
                                            card: Card(cardID: "68762510", cardName: "Lucky Pied Piper", cardColor: "Effect", cardAttribute: "Wind" , cardEffect: "")),
                         isDataLoaded: false, networkError: nil, retryCB: {})
        .padding(.horizontal)
    }
}

#Preview("Network Error") {
    NavigationStack {
        CardOfTheDayView(cotd: CardOfTheDay(date: "2025-02-24", version: 1,
                                            card: Card(cardID: "68762510", cardName: "Lucky Pied Piper", cardColor: "Effect", cardAttribute: "Wind" , cardEffect: "")),
                         isDataLoaded: false, networkError: .timeout, retryCB: {})
        .padding(.horizontal)
    }
}
