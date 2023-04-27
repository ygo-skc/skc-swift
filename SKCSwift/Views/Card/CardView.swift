//
//  CardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct CardView: View {
    var cardId: String
    
    @StateObject private var cardInformation = CardInformationViewModel()
    @StateObject private var cardSuggestions = CardSuggestionInformationViewModel()
    
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
                if (cardInformation.isDataLoaded) {
                    CardStatsView(
                        cardName: cardInformation.cardData.cardName, cardColor: cardInformation.cardData.cardColor, monsterType: cardInformation.cardData.monsterType,
                        cardEffect: cardInformation.cardData.cardEffect, monsterAssociation: cardInformation.cardData.monsterAssociation,
                        cardId: cardInformation.cardData.cardID, cardAttribute: cardInformation.cardData.cardAttribute,
                        monsterAttack: cardInformation.cardData.monsterAttack, monsterDefense: cardInformation.cardData.monsterDefense
                    )
                    
                    CardSuggestionsView(namedMaterials: cardSuggestions.namedMaterials, namedReferences: cardSuggestions.namedReferences, isDataLoaded: cardSuggestions.isDataLoaded)
                    
                    RelatedContentView(
                        cardName: cardInformation.cardData.cardName, products: cardInformation.getProducts(), tcgBanLists: cardInformation.getBanList(format: BanListFormat.tcg),
                        mdBanLists: cardInformation.getBanList(format: BanListFormat.md), dlBanLists: cardInformation.getBanList(format: BanListFormat.dl)
                    )
                } else {
                    RectPlaceholderView(width: .infinity, height: 200, radius: 10)
                }
            }
            .padding(.horizontal, 5)
            .onAppear {
                cardInformation.fetchData(cardId: cardId)
                cardSuggestions.fetchData(cardId: cardId)
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