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
    private(set) var error: Error?
    
    func fetchData(cardID: String) async {
        if self.card == nil {
            do {
                let card = try await data(Card.self, url: cardInfoURL(cardID: cardID))
                Task { @MainActor in
                    self.card = card
                }
            } catch let error {
                self.error = error
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
