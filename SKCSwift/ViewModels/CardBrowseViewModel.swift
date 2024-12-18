//
//  CardBrowseViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/23/24.
//

import Foundation

@Observable
final class CardBrowseViewModel {
    var showFilters = false
    var filters: CardFilters?
    
    private(set) var cards: [Card] = []
    
    private(set) var criteriaError: NetworkError?
    private(set) var criteriaStatus = DataTaskStatus.uninitiated
    private(set) var dataError: NetworkError?
    private(set) var dataStatus = DataTaskStatus.uninitiated
    
    @ObservationIgnored
    private var cardBrowseCriteria: CardBrowseCriteria?
    
    @MainActor
    func fetchCardBrowseCriteria() async {
        if criteriaError != nil || cardBrowseCriteria == nil {
            switch await data(CardBrowseCriteria.self, url: cardBrowseCriteriaURL()) {
            case .success(let cardBrowseCriteria):
                self.cardBrowseCriteria = cardBrowseCriteria
                
                let attributeFilters = cardBrowseCriteria.attributes.map { attribute in
                    FilteredItem(category: attribute, isToggled: false, disableToggle: false)
                }
                let cardColorFilters = cardBrowseCriteria.cardColors.map { cardColor in
                    FilteredItem(category: cardColor, isToggled: false, disableToggle: false)
                }
                
                filters = CardFilters(attributes: attributeFilters, colors: cardColorFilters)
                criteriaError = nil
            case .failure(let error):
                criteriaError = error
            }
            criteriaStatus = .done
        }
    }
    
    @MainActor
    func fetchCards() async {
        if let filters {
            let attributes = filters.attributes.filter { $0.isToggled }.map{ $0.category }
            let colors = filters.colors.filter { $0.isToggled }.map{ $0.category }
            
            if !attributes.isEmpty || !colors.isEmpty {
                switch await data(CardBrowseResults.self, url: cardBrowseURL(attributes: attributes, colors: colors)) {
                case .success(let r):
                    cards = r.results
                    dataError = nil
                case .failure(let error):
                    dataError = error
                }
                dataStatus = .done
            }
        }
    }
}
