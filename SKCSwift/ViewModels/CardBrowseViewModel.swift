//
//  CardBrowseViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/23/24.
//

import Foundation

@Observable
class CardBrowseViewModel {
    var showFilters = false
    var filters: CardFilters?
    var cards: [Card] = []
    
    @ObservationIgnored
    private var numResults: UInt = 0
    @ObservationIgnored
    private var cardBrowseCriteria: CardBrowseCriteria?
    
    func fetchCardBrowseCriteria() async {
        if cardBrowseCriteria == nil, let cardBrowseCriteria = try? await data(CardBrowseCriteria.self, url: cardBrowseCriteriaURL()) {
            self.cardBrowseCriteria = cardBrowseCriteria
            
            let attributeFilters = cardBrowseCriteria.attributes.map { attribute in
                FilteredItem(category: attribute, isToggled: false, disableToggle: false)
            }
            let cardColorFilters = cardBrowseCriteria.cardColors.map { cardColor in
                FilteredItem(category: cardColor, isToggled: false, disableToggle: false)
            }
            
            Task { @MainActor in
                self.filters = CardFilters(attributes: attributeFilters, colors: cardColorFilters)
            }
        }
    }
    
    func fetchCards() async {
        if let filters {
            let attributes = filters.attributes.filter { $0.isToggled }.map{ $0.category }
            let colors = filters.colors.filter { $0.isToggled }.map{ $0.category }
            
            if !attributes.isEmpty || !colors.isEmpty,
                let r = try? await data(CardBrowseResults.self, url: cardBrowseURL(attributes: attributes, colors: colors)) {
                self.numResults = r.numResults
                Task { @MainActor in
                    self.cards = r.results
                }
            }
        }
    }
}