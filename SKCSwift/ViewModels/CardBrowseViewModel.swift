//
//  CardBrowseViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/23/24.
//

import Foundation

@MainActor
@Observable
final class CardBrowseViewModel {
    var showFilters = false
    var filters = CardFilters(attributes: [], colors: [], levels: [])
    
    private(set) var cards: [Card] = []
    
    private(set) var criteriaError: NetworkError?
    private(set) var criteriaStatus = DataTaskStatus.uninitiated
    private(set) var dataError: NetworkError?
    private(set) var dataStatus = DataTaskStatus.uninitiated
    
    @ObservationIgnored
    private var cardBrowseCriteria: CardBrowseCriteria?
    
    func fetchCardBrowseCriteria() async {
        if criteriaError != nil || cardBrowseCriteria == nil {
            switch await data(cardBrowseCriteriaURL(), resType: CardBrowseCriteria.self) {
            case .success(let cardBrowseCriteria):
                self.cardBrowseCriteria = cardBrowseCriteria
                filters = await resetFilters(cardBrowseCriteria)
                criteriaError = nil
            case .failure(let error):
                criteriaError = error
            }
            criteriaStatus = .done
        }
    }
    
    func fetchCards() async {
        let (attributes, colors, levels) = await determineToggledFilters(filters)
        switch await data(cardBrowseURL(attributes: attributes, colors: colors, levels: levels), resType: CardBrowseResults.self) {
        case .success(let r):
            cards = r.results
            dataError = nil
        case .failure(let error):
            dataError = error
        }
        dataStatus = .done
    }
    
    private nonisolated func resetFilters(_ cardBrowseCriteria: CardBrowseCriteria) async -> CardFilters {
        return await Task.detached {
            let attributeFilters = cardBrowseCriteria.attributes.map { attribute in
                FilteredItem(category: attribute, isToggled: false, disableToggle: false)
            }
            let cardColorFilters = cardBrowseCriteria.cardColors.map { cardColor in
                FilteredItem(category: cardColor, isToggled: false, disableToggle: false)
            }
            let monsterLevelFilters = cardBrowseCriteria.levels.map { level in
                FilteredItem(category: level, isToggled: false, disableToggle: false)
            }
            
            return CardFilters(attributes: attributeFilters, colors: cardColorFilters, levels: monsterLevelFilters)
        }.value
    }
    
    private nonisolated func determineToggledFilters(_ filters: CardFilters) async -> ([String], [String], [String]) {
        return await Task.detached {
            let attributes = filters.attributes.filter { $0.isToggled }.map{ $0.category }
            let colors = filters.colors.filter { $0.isToggled }.map{ $0.category }
            let levels = filters.levels.filter { $0.isToggled }.map{ String($0.category) }
            
            return (attributes, colors, levels)
        }.value
    }
}
