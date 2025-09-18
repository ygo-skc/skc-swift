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
    private(set) var requestErrors: [CardModelDataType: NetworkError?] = [:]
    
    private(set) var areSuggestionsLoaded = false
    private(set) var isSupportLoaded = false
    
    @ObservationIgnored
    private(set) var namedMaterials: [CardReference]?
    @ObservationIgnored
    private(set) var namedReferences: [CardReference]?
    @ObservationIgnored
    private(set) var referencedBy: [CardReference]?
    @ObservationIgnored
    private(set) var materialFor: [CardReference]?
    
    @ObservationIgnored
    let cardID: String
    
    init(cardID: String) {
        self.cardID = cardID
    }
    
    func fetchCardData(forceRefresh: Bool = false) async {
        if forceRefresh || card == nil {
            switch await data(cardInfoURL(cardID: cardID), resType: Card.self) {
            case .success(let card):
                self.card = card
                requestErrors[.card] = nil
            case .failure(let error):
                requestErrors[.card] = error
            }
        }
    }
    
    func fetchAllSuggestions(forceRefresh: Bool = false) async {
        await withTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask { await self.fetchSuggestions(forceRefresh: forceRefresh) }
            taskGroup.addTask { await self.fetchSupport(forceRefresh: forceRefresh) }
        }
    }
    
    private func fetchSuggestions(forceRefresh: Bool = false) async {
        if forceRefresh || !areSuggestionsLoaded {
            switch await data(cardSuggestionsURL(cardID: cardID), resType: CardSuggestions.self) {
            case .success(let suggestions):
                namedMaterials = suggestions.namedMaterials
                namedReferences = suggestions.namedReferences
                areSuggestionsLoaded = true
                requestErrors[.suggestions] = nil
            case .failure(let error):
                requestErrors[.suggestions] = error
            }
        }
    }
    
    private func fetchSupport(forceRefresh: Bool = false) async {
        if forceRefresh || !isSupportLoaded {
            switch await data(cardSupportURL(cardID: cardID), resType: CardSupport.self) {
            case .success(let support):
                referencedBy = support.referencedBy
                materialFor = support.materialFor
                isSupportLoaded = true
                requestErrors[.support] = nil
            case .failure(let error):
                requestErrors[.support] = error
            }
        }
    }
    
    func hasSuggestions() -> Bool {
        if let namedMaterials, let namedReferences, let referencedBy, let materialFor,
            namedMaterials.isEmpty && namedReferences.isEmpty && referencedBy.isEmpty && materialFor.isEmpty {
            return false
        }
        return true
    }
    
    func resetCardError() {
        requestErrors[.card] = nil
    }
    
    func resetSuggestionErrors() {
        requestErrors[.suggestions] = nil
        requestErrors[.support] = nil
    }
    
    func suggestionRequestHasErrors() -> Bool {
        return requestErrors[.suggestions] != nil && requestErrors[.support] != nil
    }
    
    enum CardModelDataType {
        case card, suggestions, support
    }
}
