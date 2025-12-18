//
//  CardOfTheDayView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import SwiftUI

struct CardOfTheDayView: View, Equatable {
    static func == (lhs: CardOfTheDayView, rhs: CardOfTheDayView) -> Bool {
        lhs.cotd == rhs.cotd && lhs.dataTaskStatus == rhs.dataTaskStatus && lhs.networkError == rhs.networkError
    }
    
    @Binding var path: NavigationPath
    let cotd: CardOfTheDay
    let dataTaskStatus: DataTaskStatus
    let networkError: NetworkError?
    let retryCB: () async -> Void
    
    private static let IMAGE_SIZE: CGFloat = 90
    
    var body: some View {
        SectionView(
            header: "Card of the day",
            content: {
                if let networkError {
                    NetworkErrorView(error: networkError, action: { Task { await retryCB() } })
                } else {
                    Button {
                        path.append(CardLinkDestinationValue(cardID: cotd.card.cardID, cardName: cotd.card.cardName))
                    } label: { CardOfTheDayContentsView(cotd: cotd, isDataLoaded: dataTaskStatus == .done) }
                        .disabled(dataTaskStatus != .done && networkError == nil)
                        .buttonStyle(.plain)
                }
            }
        )
    }
    
    private struct CardOfTheDayContentsView: View {
        let cotd: CardOfTheDay
        let isDataLoaded: Bool
        
        init(cotd: CardOfTheDay, isDataLoaded: Bool) {
            self.cotd = (cotd.date.isEmpty) ? CardOfTheDay(date: "1991-07-27", version: 0, card: .placeholder) : cotd
            self.isDataLoaded = isDataLoaded
        }
        
        var body: some View {
            HStack(alignment: .top, spacing: 20) {
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
            .if(!isDataLoaded) {
                $0.redacted(reason: .placeholder)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
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
