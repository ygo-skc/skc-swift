//
//  CardBrowseViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/23/24.
//

import Foundation

fileprivate actor CardBrowseActor {
    private var wasCriteriaFetched = false
    
    fileprivate func fetchCriteria(filters previousFilters: CardFilters) async -> (CardFilters, NetworkError?) {
        if !wasCriteriaFetched {
            switch await data(cardBrowseCriteriaURL(), resType: CardBrowseCriteria.self) {
            case .success(let cardBrowseCriteria):
                wasCriteriaFetched = true
                return (await resetFilters(cardBrowseCriteria), nil)
            case .failure(let error):
                return (previousFilters, error)
            }
        }
        return (previousFilters, nil)
    }
    
    fileprivate func fetchCards(filters: CardFilters) async -> ([Card], NetworkError?) {
        let (attributes, colors, levels, ranks, linkRatings) = await determineToggledFilters(filters)
        switch await data(cardBrowseURL(attributes: attributes, colors: colors, levels: levels, ranks: ranks, linkRatings: linkRatings), resType: CardBrowseResults.self) {
        case .success(let r):
            return (r.results, nil)
        case .failure(let error):
            return ([], error)
        }
    }
    
    private func resetFilters(_ cardBrowseCriteria: CardBrowseCriteria) async -> CardFilters {
        let attributeFilters = cardBrowseCriteria.attributes.map { attribute in
            FilteredItem(category: attribute, isToggled: false, disableToggle: false)
        }
        let cardColorFilters = cardBrowseCriteria.cardColors.map { cardColor in
            FilteredItem(category: cardColor, isToggled: false, disableToggle: false)
        }
        let monsterLevelFilters = cardBrowseCriteria.levels.map { level in
            FilteredItem(category: level, isToggled: false, disableToggle: false)
        }
        let monsterRankFilters = cardBrowseCriteria.ranks.map { rank in
            FilteredItem(category: rank, isToggled: false, disableToggle: false)
        }
        let monsterLinkRatingFilter = cardBrowseCriteria.linkRatings.map { linkRating in
            FilteredItem(category: linkRating, isToggled: false, disableToggle: false)
        }
        
        return CardFilters(attributes: attributeFilters, colors: cardColorFilters, levels: monsterLevelFilters,
                           ranks: monsterRankFilters, linkRatings: monsterLinkRatingFilter)
    }
    
    private func determineToggledFilters(_ filters: CardFilters) async -> ([String], [String], [String], [String], [String]) {
        let attributes = filters.attributes.filter { $0.isToggled }.map{ $0.category }
        let colors = filters.colors.filter { $0.isToggled }.map{ $0.category }
        let levels = filters.levels.filter { $0.isToggled }.map{ String($0.category) }
        let ranks = filters.ranks.filter { $0.isToggled }.map{ String($0.category) }
        let linkRatings = filters.linkRatings.filter { $0.isToggled }.map{ String($0.category) }
        
        return (attributes, colors, levels, ranks, linkRatings)
    }
}

@MainActor
@Observable
final class CardBrowseViewModel {
    var showFilters = false
    var filters = CardFilters()
    
    private(set) var cards: [Card] = []
    
    private(set) var criteriaError: NetworkError?
    private(set) var criteriaStatus = DataTaskStatus.uninitiated
    
    private(set) var dataError: NetworkError?
    private(set) var dataStatus = DataTaskStatus.uninitiated
    
    @ObservationIgnored
    private let cardBrowseActor = CardBrowseActor()
    
    func fetchCardBrowseCriteria() async {
        criteriaError = nil
        criteriaStatus = .pending
        (filters, criteriaError) = await cardBrowseActor.fetchCriteria(filters: filters)
        criteriaStatus = .done
    }
    
    func fetchCards() async {
        dataError = nil
        dataStatus = .pending
        (cards, dataError) = await cardBrowseActor.fetchCards(filters: filters)
        dataStatus = .done
    }
}
