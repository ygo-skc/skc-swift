//
//  CardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/26/24.
//
import Foundation
import YGOService
import GRPCCore

private nonisolated struct YGOCardInfo: Codable, Equatable {
    let cardID: String
    let cardName: String
    let cardColor: String
    let cardAttribute: String?
    let cardEffect: String
    let monsterType: String?
    let monsterAssociation: MonsterAssociation?
    let monsterAttack: Int?
    let monsterDefense: Int?
    let restrictedIn: BanListsForCard?
    let foundIn: [Product]?
    
    init(cardID: String,
         cardName: String,
         cardColor: String,
         cardAttribute: String?,
         cardEffect: String,
         monsterType: String? = nil,
         monsterAssociation: MonsterAssociation? = nil,
         monsterAttack: Int? = nil,
         monsterDefense: Int? = nil,
         restrictedIn: BanListsForCard? = nil,
         foundIn: [Product]? = nil) {
        self.cardID = cardID
        self.cardName = cardName
        self.cardColor = cardColor
        self.cardAttribute = cardAttribute
        self.cardEffect = cardEffect
        self.monsterType = monsterType
        self.monsterAssociation = monsterAssociation
        self.monsterAttack = monsterAttack
        self.monsterDefense = monsterDefense
        self.restrictedIn = restrictedIn
        self.foundIn = foundIn
    }
}

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
    private(set) var card: YGOCard?
    @ObservationIgnored
    private(set) var products: [Product]?
    @ObservationIgnored
    private(set) var restrictions: BanListsForCard?
    private(set) var score: CardScore?
    
    @ObservationIgnored
    private(set) var namedMaterials: [CardReference] = []
    @ObservationIgnored
    private(set) var namedReferences: [CardReference] = []
    @ObservationIgnored
    private(set) var referencedBy: [CardReference] = []
    @ObservationIgnored
    private(set) var materialFor: [CardReference] = []
    
    @ObservationIgnored
    private(set) var archetypeSuggestions: Set<String> = []
    
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
            (cardNE, cardDTS) = (nil, .pending)
            let res = await data(cardInfoURL(cardID: cardID), resType: YGOCardInfo.self)
            if case .success(let card) = res {
                self.card = .init(cardID: card.cardID,
                                  cardName: card.cardName,
                                  cardColor: card.cardColor,
                                  cardAttribute: card.cardAttribute,
                                  cardEffect: card.cardEffect,
                                  monsterType: card.monsterType,
                                  monsterAssociation: card.monsterAssociation,
                                  monsterAttack: card.monsterAttack,
                                  monsterDefense: card.monsterDefense)
                self.products = card.foundIn
                self.restrictions = card.restrictedIn
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
        (suggestionsNE, suggestionsDTS) = (nil, .pending)
        let res = await data(cardSuggestionsURL(cardID: cardID), resType: CardSuggestions.self)
        if case .success(let suggestions) = res {
            namedMaterials = suggestions.namedMaterials
            namedReferences = suggestions.namedReferences
            archetypeSuggestions = Set(suggestions.materialArchetypes + suggestions.referencedArchetypes)
        }
        (suggestionsNE, suggestionsDTS) = res.validate()
    }
    
    private func fetchSupport() async {
        (supportNE, supportDTS) = (nil, .pending)
        let res = await data(cardSupportURL(cardID: cardID), resType: CardSupport.self)
        if case .success(let support) = res {
            referencedBy = support.referencedBy
            materialFor = support.materialFor
        }
        (supportNE, supportDTS) = res.validate()
    }
    
    func hasSuggestions() -> Bool {
        return !(namedMaterials.isEmpty && namedReferences.isEmpty && referencedBy.isEmpty && materialFor.isEmpty && archetypeSuggestions.isEmpty)
    }
}
