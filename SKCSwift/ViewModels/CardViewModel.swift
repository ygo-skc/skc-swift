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
    
    @MainActor
    func fetchCardData(forceRefresh: Bool = false) async {
        if forceRefresh || card == nil {
            switch await data(Card.self, url: cardInfoURL(cardID: cardID)) {
            case .success(let card):
                self.card = card
                requestErrors[.card] = nil
            case .failure(let error):
                requestErrors[.card] = error
            }
        }
    }
    
    @MainActor
    func fetchSuggestions() async {
        if !areSuggestionsLoaded {
            switch await data(CardSuggestions.self, url: cardSuggestionsURL(cardID: cardID)) {
            case .success(let suggestions):
                namedMaterials = suggestions.namedMaterials
                namedReferences = suggestions.namedReferences
                areSuggestionsLoaded = true
            case.failure(_): break
            }
        }
    }
    
    @MainActor
    func fetchSupport() async {
        if !isSupportLoaded {
            switch await data(CardSupport.self, url: cardSupportURL(cardID: cardID)) {
            case .success(let support):
                referencedBy = support.referencedBy
                materialFor = support.materialFor
                isSupportLoaded = true
            case .failure(_): break
            }
        }
    }
    
    enum CardModelDataType: String, Codable, CaseIterable {
        case card, suggestions, support
    }
}
