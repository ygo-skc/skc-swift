//
//  CardOfTheDayView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import SwiftUI

struct CardOfTheDayView: View {
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
            
            request(url: cardOfTheDayURL()) { (result: Result<CardOfTheDay, Error>) -> Void in
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
    
    var body: some View {
        SectionView(
            header: "Card of the day",
            disableDestination: !isDataLoaded,
            destination: {CardSearchLinkDestination(cardID: card.cardID)},
            content: {
                HStack(alignment: .top, spacing: 20) {
                    RoundedImageView(radius: 90, imageUrl: URL(string: "https://images.thesupremekingscastle.com/cards/tn/\(card.cardID).jpg")!)
                    VStack(alignment: .leading, spacing: 5) {
                        if isDataLoaded {
                            InlineDateView(date: date)
                            Text(card.cardName)
                                .lineLimit(2)
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            HStack {
                                CardColorIndicator(cardColor: card.cardColor, variant: .small)
                                Text(card.cardType())
                                    .font(.headline)
                            }
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
            }
        )
        .task(priority: .background) {
            fetchData()
        }
        .onChange(of: $isDataInvalidated.wrappedValue) { _ in
            fetchData()
        }
    }
}

struct CardOfTheDayView_Previews: PreviewProvider {
    static var previews: some View {
        CardOfTheDayView()
    }
}
