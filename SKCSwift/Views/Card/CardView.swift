//
//  CardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct CardView: View {
    var cardID: String
    
    @ObservedObject private var model: CardInformationViewModel
    
    init(cardID: String) {
        self.cardID = cardID
        self.model = CardInformationViewModel(cardID: cardID)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                YGOCardView(card: model.cardData, isDataLoaded: model.isDataLoaded)
                if (model.isDataLoaded) {
                    RelatedContentView(
                        cardName: model.cardData.cardName,
                        products: model.getProducts(),
                        tcgBanLists: model.getBanList(format: BanListFormat.tcg),
                        mdBanLists: model.getBanList(format: BanListFormat.md), dlBanLists: model.getBanList(format: BanListFormat.dl)
                    )
                    CardSuggestionsView(cardId: cardID)
                }
            }
            .onAppear {
                model.fetchData()
            }
            .frame(maxHeight: .infinity)
        }
        .navigationTitle("Card")
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(cardID: "90307498")
    }
}
