//
//  CardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/26/24.
//
import Foundation
import YGOService
import GRPCCore

@Observable
final class CardViewModel {
    @ObservationIgnored
    let cardID: String
    
    init(cardID: String) {
        self.cardID = cardID
    }
    
    private(set) var cardDTS: DataTaskStatus = .pending
    private(set) var cardScoreDTS: DataTaskStatus = .pending
    
    private(set) var suggestionsDTS: DataTaskStatus = .pending
    private(set) var supportDTS: DataTaskStatus = .pending
    
    @ObservationIgnored
    private(set) var cardNE: NetworkError?
    @ObservationIgnored
    private(set) var cardScoredNE: NetworkError?
    @ObservationIgnored
    private(set) var suggestionsNE: NetworkError?
    @ObservationIgnored
    private(set) var supportNE: NetworkError?
    
    @ObservationIgnored
    private(set) var card: Card?
    private(set) var score: CardScore?
    
    @ObservationIgnored
    private(set) var namedMaterials: [CardReference]?
    @ObservationIgnored
    private(set) var namedReferences: [CardReference]?
    @ObservationIgnored
    private(set) var referencedBy: [CardReference]?
    @ObservationIgnored
    private(set) var materialFor: [CardReference]?
    
    @ObservationIgnored
    var areSuggestionsLoaded: Bool { suggestionsDTS == .done && supportDTS == .done }
    @ObservationIgnored
    var suggestionsError: NetworkError? {
        return (suggestionsNE != nil) ? suggestionsNE : supportNE
    }
    
    func fetchCardInfo(forceRefresh: Bool = false) async {
        await withTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask { await self.fetchCardData(forceRefresh: forceRefresh) }
            taskGroup.addTask { await self.fetchCardScore() }
        }
    }
    
    private func fetchCardData(forceRefresh: Bool = false) async {
        if forceRefresh || card == nil {
            cardDTS = .pending
            let res = await data(cardInfoURL(cardID: cardID), resType: Card.self)
            if case .success(let card) = res {
                self.card = card
            }
            (cardNE, cardDTS) = res.validate()
        }
    }
    
    private func fetchCardScore() async {
        if score == nil {
            cardScoreDTS = .pending
            let res = await YGOService.getCardScore(cardID: cardID, mapper: CardScore.fromRPC)
            if case .success(let score) = res {
                self.score = score
            }
            (cardScoredNE, cardScoreDTS) = res.validate(method: "Card Score Timeline")
        }
    }
    
    func fetchAllSuggestions(forceRefresh: Bool = false) async {
        if forceRefresh || !areSuggestionsLoaded || suggestionsError != nil {
            await withTaskGroup(of: Void.self) { taskGroup in
                taskGroup.addTask { await self.fetchSuggestions() }
                taskGroup.addTask { await self.fetchSupport() }
            }
        }
    }
    
    private func fetchSuggestions() async {
        suggestionsDTS = .pending
        let res = await data(cardSuggestionsURL(cardID: cardID), resType: CardSuggestions.self)
        if case .success(let suggestions) = res {
            namedMaterials = suggestions.namedMaterials
            namedReferences = suggestions.namedReferences
        }
        (suggestionsNE, suggestionsDTS) = res.validate()
    }
    
    private func fetchSupport() async {
        supportDTS = .pending
        let res = await data(cardSupportURL(cardID: cardID), resType: CardSupport.self)
        if case .success(let support) = res {
            referencedBy = support.referencedBy
            materialFor = support.materialFor
        }
        (supportNE, supportDTS) = res.validate()
    }
    
    func hasSuggestions() -> Bool {
        if let namedMaterials, let namedReferences, let referencedBy, let materialFor,
           namedMaterials.isEmpty && namedReferences.isEmpty && referencedBy.isEmpty && materialFor.isEmpty {
            return false
        }
        return true
    }
}
