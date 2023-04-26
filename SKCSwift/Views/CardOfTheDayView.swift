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
                Text("Card of the Day")
                    .font(.title)
                    .padding(.top)
                Text(cardOfTheDay.card.cardName)
            }
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
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
