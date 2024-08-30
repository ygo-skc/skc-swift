//
//  CardSuggestionViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/13/24.
//

import Foundation

@Observable
class CardSuggestionViewModel {
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
    
    func fetchSuggestions(cardID: String) async {
        if !areSuggestionsLoaded {
            switch await data(CardSuggestions.self, url: cardSuggestionsURL(cardID: cardID)) {
            case .success(let suggestions):
                self.namedMaterials = suggestions.namedMaterials
                self.namedReferences = suggestions.namedReferences
                DispatchQueue.main.async {
                    self.areSuggestionsLoaded = true
                }
            case.failure(_): break
            }
        }
    }
    
    func fetchSupport(cardID: String) async {
        if !isSupportLoaded {
            switch await data(CardSupport.self, url: cardSupportURL(cardID: cardID)) {
            case .success(let support):
                self.referencedBy = support.referencedBy
                self.materialFor = support.materialFor
                DispatchQueue.main.async {
                    self.isSupportLoaded = true
                }
            case .failure(_): break
            }
        }
    }
}
