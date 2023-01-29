//
//  CardSuggestionViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/24/23.
//

import SwiftUI

struct SuggestedCardViewModel: View {
    var cardId: String
    var cardName: String
    var cardColor: String
    var cardEffect: String
    var cardAttribute: String
    var monsterType: String?
    var occurrence: Int
    
    var body: some View {
        VStack {
            HStack {
                RoundedImageViewModel(radius: 100, imageUrl: URL(string: "https://images.thesupremekingscastle.com/cards/lg/\(cardId).jpg")!)
            
                Text("Quantity: \(occurrence)")
                    .padding(.leading)
                    .font(.headline)
                    .fontWeight(.heavy)
            }
            
            CardStatsViewModel(cardName: cardName, cardColor: cardColor, monsterType: monsterType, cardEffect: cardEffect, cardId: cardId, cardAttribute: cardAttribute, showAllInfo: false)
        }
        .frame(width: 250)
    }
}

struct SuggestedCardViewModel_Preview: PreviewProvider {
    static var previews: some View {
        SuggestedCardViewModel(cardId: "40044918", cardName: "Elemental HERO Stratos", cardColor: "Effect", cardEffect: "Draw 2", cardAttribute: "Wind", monsterType: "Warrior/Effect", occurrence: 1)
    }
}
