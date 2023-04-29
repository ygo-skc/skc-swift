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
    
    private let imageSize = UIScreen.main.bounds.width - 60
    private let imageUrl: URL
    
    init(cardId: String) {
        self.cardId = cardId
        self.imageUrl =  URL(string: "https://images.thesupremekingscastle.com/cards/lg/\(cardId).jpg")!
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                RoundedRectImage(width: imageSize, height: imageSize, imageUrl: imageUrl)
                if (cardInformationViewModel.isDataLoaded) {
                    CardStatsView(
                        cardName: cardInformationViewModel.cardData.cardName, cardColor: cardInformationViewModel.cardData.cardColor, monsterType: cardInformationViewModel.cardData.monsterType,
                        cardEffect: cardInformationViewModel.cardData.cardEffect, monsterAssociation: cardInformationViewModel.cardData.monsterAssociation,
                        cardId: cardInformationViewModel.cardData.cardID, cardAttribute: cardInformationViewModel.cardData.cardAttribute,
                        monsterAttack: cardInformationViewModel.cardData.monsterAttack, monsterDefense: cardInformationViewModel.cardData.monsterDefense
                    )
                    
                    RelatedContentView(
                        cardName: cardInformationViewModel.cardData.cardName, products: cardInformationViewModel.getProducts(), tcgBanLists: cardInformationViewModel.getBanList(format: BanListFormat.tcg),
                        mdBanLists: cardInformationViewModel.getBanList(format: BanListFormat.md), dlBanLists: cardInformationViewModel.getBanList(format: BanListFormat.dl)
                    )
                    
                    CardSuggestionsView(cardId: cardId)
                } else {
                    RectPlaceholderView(width: .infinity, height: 200, radius: 10)
                }
            }
            .padding(.horizontal, 5)
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
