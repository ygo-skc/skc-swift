//
//  CardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/26/24.
//
import Foundation

@Observable
final class CardViewModel {
    private(set) var card: Card?
    var error: NetworkError?
    
    func fetchData(cardID: String) async {
        if self.card == nil {
            switch await data(Card.self, url: cardInfoURL(cardID: cardID)) {
            case .success(let card):
                Task { @MainActor in
                    self.card = card
                }
            case .failure(let error):
                Task { @MainActor in
                    self.error = error
                }
            }
        }
    }
    
    func getProducts() -> [Product] {
        return card?.foundIn ?? [Product]()
    }
    
    func getBanList(format: BanListFormat) -> [BanList] {
        switch format {
        case .tcg:
            return card?.restrictedIn?.TCG ?? [BanList]()
        case .md:
            return card?.restrictedIn?.MD ?? [BanList]()
        case .dl:
            return card?.restrictedIn?.DL ?? [BanList]()
        }
    }
}
