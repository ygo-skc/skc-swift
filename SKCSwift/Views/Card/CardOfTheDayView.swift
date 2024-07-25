//
//  CardOfTheDayView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import SwiftUI

struct CardOfTheDayView: View, Equatable {
    @Binding private var isDataInvalidated: Bool
    
    @State private var date: String = ""
    @State private var card: Card = Card(cardID: "", cardName: "", cardColor: "", cardAttribute: "", cardEffect: "")
    @State private var isDataLoaded = false
    
    init(isDataInvalidated: Binding<Bool> = .constant(false)) {
        self._isDataInvalidated = isDataInvalidated
    }
    
    func fetchData() {
        if !isDataLoaded || isDataInvalidated {
            self.isDataInvalidated = false
            
            request(url: cardOfTheDayURL(), priority: 0.25) { (result: Result<CardOfTheDay, Error>) -> Void in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let cardOfTheyDay):
                        if self.date != cardOfTheyDay.date {
                            self.date = cardOfTheyDay.date
                            self.card = cardOfTheyDay.card
                        }
                        self.isDataLoaded = true
                        self.isDataInvalidated = false
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    static func == (lhs: CardOfTheDayView, rhs: CardOfTheDayView) -> Bool {
        return lhs.card.cardID == rhs.card.cardID
    }
    
    var body: some View {
        SectionView(
            header: "Card of the day",
            content: {
                NavigationLink(value: CardValue(cardID: card.cardID, cardName: card.cardName), label: {
                    HStack(alignment: .top, spacing: 20) {
                        YGOCardImage(height: 90, imgSize: .tiny, cardID: card.cardID)
                            .overlay(
                                Circle()
                                    .if(card.cardColor.starts(with: "Pendulum")) {
                                        $0.stroke(cardColorGradient(cardColor: card.cardColor), lineWidth: 5)
                                    } else: {
                                        $0.stroke(cardColorUI(cardColor: card.cardColor), lineWidth: 5)
                                    }
                            )
                        VStack(alignment: .leading, spacing: 5) {
                            if isDataLoaded {
                                InlineDateView(date: date)
                                    .equatable()
                                Text(card.cardName)
                                    .lineLimit(2)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Text(card.cardType())
                                    .font(.headline)
                            } else {
                                PlaceholderView(width: 200, height: 18, radius: 5)
                                PlaceholderView(width: 120, height: 18, radius: 5)
                                PlaceholderView(width: 60, height: 18, radius: 5)
                            }
                        }
                        .frame(
                            maxWidth: .infinity,
                            alignment: .topLeading
                        )
                    }
                    .contentShape(Rectangle())
                })
                .buttonStyle(.plain)
                .disabled(!isDataLoaded)
            }
        )
        .onChange(of: $isDataInvalidated.wrappedValue, initial: true) {
            fetchData()
        }
    }
}


#Preview {
    CardOfTheDayView()
}

