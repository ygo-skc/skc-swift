//
//  CardOfTheDayView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import SwiftUI

struct CardOfTheDayView: View {
    @State private(set) var date: String = ""
    @State private(set) var card: Card = Card(cardID: "", cardName: "", cardColor: "", cardAttribute: "", cardEffect: "")
    @State private(set) var isDataLoaded = false
    
    func fetchData() {
        if isDataLoaded {
            return
        }
        request(url: cardOfTheDayURL()) { (result: Result<CardOfTheDay, Error>) -> Void in
            DispatchQueue.main.async {
                switch result {
                case .success(let cardOfTheyDay):
                    self.date = cardOfTheyDay.date
                    self.card = cardOfTheyDay.card
                    self.isDataLoaded = true
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    var body: some View {
        SectionView(
            header: "Card of the day",
            disableDestination: !isDataLoaded,
            destination: {CardSearchLinkDestination(cardId: card.cardID)},
            content: {
                HStack(spacing: 20) {
                    RoundedImageView(radius: 90, imageUrl: URL(string: "https://images.thesupremekingscastle.com/cards/tn/\(card.cardID).jpg")!)
                    VStack(alignment: .leading, spacing: 3) {
                        if isDataLoaded {
                            Text(card.cardName)
                                .lineLimit(2)
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            if let monsterType = card.monsterType {
                                Text(monsterType)
                                    .font(.headline)
                                    .fontWeight(.regular)
                            }
                            
                            HStack {
                                Circle()
                                    .foregroundColor(cardColorUI(cardColor: card.cardColor))
                                    .frame(width: 10)
                                Text(card.cardColor)
                                    .font(.headline)
                                    .fontWeight(.regular)
                            }
                        } else {
                            RectPlaceholderView(width: 200, height: 18, radius: 5)
                            RectPlaceholderView(width: 120, height: 18, radius: 5)
                            RectPlaceholderView(width: 60, height: 18, radius: 5)
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
        .onAppear{
            fetchData()
        }
    }
}

struct CardOfTheDayView_Previews: PreviewProvider {
    static var previews: some View {
        CardOfTheDayView()
    }
}
