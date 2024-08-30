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
    var error: DataFetchError?
    
    func fetchData(cardID: String) async {
        if self.card == nil {
            do {
                let card = try await data(Card.self, url: cardInfoURL(cardID: cardID))
                Task { @MainActor in
                    self.card = card
                }
            } catch let error as DataFetchError {
                Task { @MainActor in
                    self.error = error
                }
            } catch {
                
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
