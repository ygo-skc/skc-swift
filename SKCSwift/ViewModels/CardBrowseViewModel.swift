//
//  CardBrowseViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/23/24.
//

import Foundation

@Observable
class CardBrowseViewModel {
    var cardColorFilters: [FilteredItem] = []
    
    @ObservationIgnored
    private var cardBrowseCriteria: CardBrowseCriteria?
    
    func fetchCardBrowseCriteria() async {
        if cardBrowseCriteria == nil, let cardBrowseCriteria = try? await data(CardBrowseCriteria.self, url: cardBrowseCriteriaURL()) {
            self.cardBrowseCriteria = cardBrowseCriteria
            
            var cardColorFilters: [FilteredItem] = []
            for cardColor in cardBrowseCriteria.cardColors {
                cardColorFilters.append(FilteredItem(category: cardColor, isToggled: false, disableToggle: false))
            }
            
            Task { @MainActor [cardColorFilters] in
                self.cardColorFilters = cardColorFilters
            }
        }
    }
}
