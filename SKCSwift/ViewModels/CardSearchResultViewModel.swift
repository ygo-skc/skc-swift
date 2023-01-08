//
//  CardSearchResultViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/8/23.
//

import SwiftUI

struct CardSearchResultViewModel: View {
    var cardId: String
    var cardName: String
    var monsterType: String?
    
    var body: some View {
        HStack {
            RoundedImageViewModel(radius: 60, imageUrl: URL(string: "https://images.thesupremekingscastle.com/cards/tn/\(cardId).jpg")!)
            VStack(alignment: .leading) {
                Text(cardName).fontWeight(.bold).font(.footnote)
                if (monsterType != nil) {
                    Text(monsterType!).fontWeight(.light).font(.footnote)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CardSearchResultViewModel_Previews: PreviewProvider {
    static var previews: some View {
        CardSearchResultViewModel(cardId: "40044918", cardName: "Elemental HERO Stratos", monsterType: "Warrior/Effect")
        CardSearchResultViewModel(cardId: "08949584", cardName: "A HERO Lives")
    }
}
