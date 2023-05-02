//
//  CardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct CardView: View {
    var cardId: String
    
    @StateObject private var cardInformationViewModel = CardInformationViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                YGOCardView(card: cardInformationViewModel.cardData, isDataLoaded: cardInformationViewModel.isDataLoaded)
                if (cardInformationViewModel.isDataLoaded) {
                    RelatedContentView(
                        cardName: cardInformationViewModel.cardData.cardName,
                        products: cardInformationViewModel.getProducts(),
                        tcgBanLists: cardInformationViewModel.getBanList(format: BanListFormat.tcg),
                        mdBanLists: cardInformationViewModel.getBanList(format: BanListFormat.md), dlBanLists: cardInformationViewModel.getBanList(format: BanListFormat.dl)
                    )
                    CardSuggestionsView(cardId: cardId)
                }
            }
            .onAppear {
                cardInformationViewModel.fetchData(cardId: cardId)
            }
            .frame(maxHeight: .infinity)
        }
        .navigationTitle("Card")
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(cardId: "90307498")
    }
}
