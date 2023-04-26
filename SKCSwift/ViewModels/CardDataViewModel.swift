//
//  CardDataViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import Foundation

@MainActor
class CardInformationViewModel: ObservableObject {
    @Published private(set) var cardData = Card(cardID: "", cardName: "", cardColor: "", cardAttribute: "", cardEffect: "", monsterType: "")
    @Published private(set) var isDataLoaded = false
    
    func fetchData(cardId: String) {
        getCardData(cardId: cardId, {result in
            DispatchQueue.main.async {
                switch result {
                case .success(let card):
                    self.cardData = card
                    self.isDataLoaded = true
                case .failure(let error):
                    print(error)
                }
            }
        })
    }
    
    func getProducts() -> [Product] {
        return cardData.foundIn ?? [Product]()
    }
    
    func getBanList(format: BanListFormat) -> [BanList] {
        switch format {
        case .tcg:
            return cardData.restrictedIn?.TCG ?? [BanList]()
        case .md:
            return cardData.restrictedIn?.MD ?? [BanList]()
        case .dl:
            return cardData.restrictedIn?.DL ?? [BanList]()
        }
    }
}
