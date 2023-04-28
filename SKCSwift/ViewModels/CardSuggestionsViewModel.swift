//
//  CardSuggestionsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import Foundation

@MainActor
class CardSuggestionViewModel: ObservableObject {
    @Published private(set) var hasSelfReference: Bool = false
    @Published private(set) var namedMaterials: [CardReference] = [CardReference]()
    @Published private(set) var namedReferences: [CardReference] = [CardReference]()
    @Published private(set) var isDataLoaded = false
    
    
    func fetchData(cardId: String) {
        if isDataLoaded {
            return
        }
        
        request(url: cardSuggestionsURL(cardId: cardId)) { (result: Result<CardSuggestions, Error>) -> Void in
            DispatchQueue.main.async {
                switch result {
                case .success(let suggestions):
                    self.hasSelfReference = suggestions.hasSelfReference
                    self.namedMaterials = suggestions.namedMaterials
                    self.namedReferences = suggestions.namedReferences
                    
                    self.isDataLoaded = true
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
