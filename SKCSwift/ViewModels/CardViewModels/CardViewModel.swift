//
//  CardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct CardViewModel: View {
    var cardId: String
    
    @State private var cardData = Card(cardID: "", cardName: "", cardColor: "", cardAttribute: "", cardEffect: "", monsterType: "")
    @State private var showProductsSheet = false
    @State private var showBanListsSheet = false
    @State private var isDataLoaded = false
    
    @State private var products = [Product]()
    @State private var tcgBanLists = [BanList]()
    @State private var mdBanLists = [BanList]()
    @State private var dlBanLists = [BanList]()
    
    
    private let imageSize = UIScreen.main.bounds.width - 60
    private let imageUrl: URL
    
    init(cardId: String) {
        self.cardId = cardId
        self.imageUrl =  URL(string: "https://images.thesupremekingscastle.com/cards/lg/\(cardId).jpg")!
    }
    
    var body: some View {
        ScrollView {
            VStack {
                RoundedRectImage(width: imageSize, height: imageSize, imageUrl: imageUrl)
                if (isDataLoaded) {
                    CardStatsViewModel(
                        cardName: cardData.cardName, cardColor: cardData.cardColor, monsterType: cardData.monsterType, cardEffect: cardData.cardEffect, monsterAssociation: cardData.monsterAssociation,
                        cardId: cardData.cardID, cardAttribute: cardData.cardAttribute, monsterAttack: cardData.monsterAttack, monsterDefense: cardData.monsterDefense
                    )
                    
                    RelatedContentViewModel(cardName: cardData.cardName, products: products, tcgBanLists: tcgBanLists, mdBanLists: mdBanLists, dlBanLists: dlBanLists)
                } else {
                    RectPlaceholderViewModel(width: imageSize, height: 200, radius: 10)
                }
            }
            .padding(.horizontal, 5)
        }
        .onAppear {
            getCardData(cardId: cardId, {result in
                switch result {
                case .success(let card):
                    self.cardData = card
                    
                    self.products = cardData.foundIn ?? [Product]()
                    self.tcgBanLists = cardData.restrictedIn?.TCG ?? [BanList]()
                    self.mdBanLists = cardData.restrictedIn?.MD ?? [BanList]()
                    self.dlBanLists = cardData.restrictedIn?.DL ?? [BanList]()
                    
                    self.isDataLoaded = true
                case .failure(let error):
                    print(error)
                }
            })
        }
    }
}

struct CardViewModel_Previews: PreviewProvider {
    static var previews: some View {
        CardViewModel(cardId: "90307498")
    }
}
