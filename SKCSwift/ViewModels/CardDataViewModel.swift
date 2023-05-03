//
//  CardDataViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import Foundation

@MainActor
class CardInformationViewModel: ObservableObject {
    private(set) var cardData: Card
    private(set) var isDataLoaded = false
    
    init(cardID: String) {
        self.cardData = Card(cardID: cardID, cardName: "", cardColor: "", cardAttribute: "", cardEffect: "", monsterType: "")
    }
    
    func fetchData() {
        if isDataLoaded {
            return
        }
        request(url: cardInfoURL(cardID: self.cardData.cardID)) { (result: Result<Card, Error>) -> Void in
            DispatchQueue.main.async {
                switch result {
                case .success(let card):
                    self.cardData = card
                    self.isDataLoaded = true
                    self.objectWillChange.send()    // update views as fields are not marked as @Published
                case .failure(let error):
                    print(error)
                }
            }
        }
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
