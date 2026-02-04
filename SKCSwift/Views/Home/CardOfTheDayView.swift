//
//  CardOfTheDayView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import SwiftUI

struct CardOfTheDayView: View, Equatable {
    static func == (lhs: CardOfTheDayView, rhs: CardOfTheDayView) -> Bool {
        lhs.cotd == rhs.cotd
        && lhs.dataTaskStatus == rhs.dataTaskStatus
    }
    
    @Binding var path: NavigationPath
    let cotd: CardOfTheDay
    let dataTaskStatus: DataTaskStatus
    let networkError: NetworkError?
    let retryCB: () async -> Void
    
    private static let IMAGE_SIZE: CGFloat = 90
    
    @ViewBuilder
    private var content: some View {
        Button {
            path.append(CardLinkDestinationValue(cardID: cotd.card.cardID, cardName: cotd.card.cardName))
        } label: {
            HStack(alignment: .top, spacing: 15) {
                CardImageView(length: CardOfTheDayView.IMAGE_SIZE, cardID: cotd.card.cardID, imgSize: .tiny, cardColor: cotd.card.cardColor)
                    .equatable()
                VStack(alignment: .leading, spacing: 5) {
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
                    
                }
            }
            .if(dataTaskStatus != .done) {
                $0.redacted(reason: .placeholder)
            }
            .contentShape(Rectangle())
        }
        .disabled(dataTaskStatus != .done && networkError == nil)
        .buttonStyle(.plain)
    }
    
    var body: some View {
        SectionView(header: "Card of the day",
                    content: {
            if let networkError {
                NetworkErrorView(error: networkError, action: { Task { await retryCB() } })
            } else {
                content
            }}
        )
    }
}

#Preview("Default") {
    @Previewable @State var path = NavigationPath()
    
    NavigationStack {
        CardOfTheDayView(path: $path,
                         cotd: CardOfTheDay(date: "2025-02-24",
                                            version: 1,
                                            card: YGOCard(cardID: "68762510",
                                                          cardName: "Lucky Pied Piper",
                                                          cardColor: "Effect",
                                                          cardAttribute: "Wind" ,
                                                          cardEffect: "")),
                         dataTaskStatus: .done, networkError: nil, retryCB: {})
        .padding(.horizontal)
    }
}

#Preview("Loading") {
    @Previewable @State var path = NavigationPath()
    
    NavigationStack {
        CardOfTheDayView(path: $path,
                         cotd: CardOfTheDay(date: "2025-02-24",
                                            version: 1,
                                            card: YGOCard(cardID: "68762510",
                                                          cardName: "Lucky Pied Piper",
                                                          cardColor: "Effect",
                                                          cardAttribute: "Wind" ,
                                                          cardEffect: "")),
                         dataTaskStatus: .pending, networkError: nil, retryCB: {})
        .padding(.horizontal)
    }
}

#Preview("Network Error") {
    @Previewable @State var path = NavigationPath()
    
    NavigationStack {
        CardOfTheDayView(path: $path,
                         cotd: CardOfTheDay(date: "2025-02-24",
                                            version: 1,
                                            card: YGOCard(cardID: "68762510",
                                                          cardName: "Lucky Pied Piper",
                                                          cardColor: "Effect",
                                                          cardAttribute: "Wind" ,
                                                          cardEffect: "")),
                         dataTaskStatus: .error, networkError: .timeout, retryCB: {})
        .padding(.horizontal)
    }
}
