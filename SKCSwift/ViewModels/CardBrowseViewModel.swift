//
//  CardBrowseViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/23/24.
//

import Foundation

@Observable
class CardBrowseViewModel {
    private(set) var cardBrowseCriteria: CardBrowseCriteria?
    
    func fetchCardBrowseCriteria() async {
        if cardBrowseCriteria == nil, let cardBrowseCriteria = try? await data(CardBrowseCriteria.self, url: cardBrowseCriteriaURL()) {
            Task(priority: .userInitiated) { @MainActor in
                self.cardBrowseCriteria = cardBrowseCriteria
            }
        }
    }
}
