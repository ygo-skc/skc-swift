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
        VStack(alignment: .leading) {
            if (cardOfTheDay.isDataLoaded) {
                HStack {
                    RoundedImageView(radius: 100, imageUrl: URL(string: "https://images.thesupremekingscastle.com/cards/sm/\(cardOfTheDay.card.cardID).jpg")!)
                    VStack(alignment: .leading) {
                        Text("Card of the Day")
                            .font(.title)
                            .multilineTextAlignment(.center)
                            
                        Text(cardOfTheDay.card.cardName)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Circle()
                                .foregroundColor(cardColorUI(cardColor: cardOfTheDay.card.cardColor))
                                .frame(width: 20)
                            Text(cardOfTheDay.card.cardColor)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    alignment: .topLeading
                )
            }
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .padding(.top)
        .onAppear{
            cardOfTheDay.fetchData()
        }
    }
}

struct CardOfTheDayView_Previews: PreviewProvider {
    static var previews: some View {
        CardOfTheDayView()
    }
}
