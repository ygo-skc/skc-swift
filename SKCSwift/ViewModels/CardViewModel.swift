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
    
    @MainActor
    func fetchData(cardID: String) async {
        if self.card == nil {
            switch await data(Card.self, url: cardInfoURL(cardID: cardID)) {
            case .success(let card):
                self.card = card
            case .failure(let error):
                self.error = error
            }
        }
    }
}
