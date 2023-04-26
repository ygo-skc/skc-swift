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
        SectionView(header: "Card of the day") {
            if (cardOfTheDay.isDataLoaded) {
                NavigationLink(destination: CardSearchLinkDestination(cardId: cardOfTheDay.card.cardID)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(cardOfTheDay.card.cardName)
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            if (cardOfTheDay.card.monsterType != nil) {
                                Text(cardOfTheDay.card.monsterType!)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            HStack {
                                Circle()
                                    .foregroundColor(cardColorUI(cardColor: cardOfTheDay.card.cardColor))
                                    .frame(width: 15)
                                Text(cardOfTheDay.card.cardColor)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .padding(.top, -10)
                        }
                        .frame(
                            maxWidth: .infinity,
                            alignment: .topLeading
                        )
                        RoundedImageView(radius: 90, imageUrl: URL(string: "https://images.thesupremekingscastle.com/cards/sm/\(cardOfTheDay.card.cardID).jpg")!)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .onAppear{
            cardOfTheDay.fetchData()
        }
    }
}

struct SectionView<Content:View>: View {
    var header: String
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(header)
                .font(.title2)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .padding(.bottom, -1)
            
            content()
                .padding(.vertical)
                .padding(.horizontal)
                .background(Color("gray"))
                .cornerRadius(15)
        }
    }
}

struct CardOfTheDayView_Previews: PreviewProvider {
    static var previews: some View {
        CardOfTheDayView()
    }
}
