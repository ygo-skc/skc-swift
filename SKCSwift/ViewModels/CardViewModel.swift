//
//  CardViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/26/24.
//
import Foundation
import GRPCCore

private nonisolated struct YGOCardInfo: Codable, Equatable {
    let cardID: String
    let cardName: String
    let cardColor: String
    let cardAttribute: String?
    let cardEffect: String
    let monsterType: String?
    let monsterAssociation: MonsterAssociation?
    let monsterAttack: UInt32?
    let monsterDefense: UInt32?
    let restrictedIn: BanListsForCard?
    let foundIn: [Product]?
    
    init(cardID: String,
         cardName: String,
         cardColor: String,
         cardAttribute: String?,
         cardEffect: String,
         monsterType: String? = nil,
         monsterAssociation: MonsterAssociation? = nil,
         monsterAttack: UInt32? = nil,
         monsterDefense: UInt32? = nil,
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

struct CardInfoPrompt {
    static let SYSTEM: StaticString = """
    You summarize Yu-Gi-Oh! card text for quick reference. Never lose anything that changes how the card is played. Never invent unstated content. No rulings, reminders, or commentary.

    Input: card name, type/subtype, effect text.

    Output: one summary.
    - If a specific summoning requirement is stated, give it first.
    - List each effect separately. Separate each section using new line.
    - After first mention, call it "this card."
    - If the card has no effect, output exactly: No effect.
    - Keep it brief.
    

    Preserve precisely for every effect:
    - Timing: Ignition (Main Phase, your turn), Trigger (fires on condition), Quick (either turn/in response), Continuous (always active), or Condition (passive restriction).
    - Optional ("you can") vs mandatory.
    - "target" only if the source text uses it.
    - Once per turn = this card only. Once per turn tied to the card's name (text like "of '[name]'") = shared across field/GY/hand/banished — label "once per turn, by name."
    - Costs (tribute, discard, banish, pay LP, detach, or anything stated before a semicolon) stay listed as costs, separate from the effect, even if the effect is later negated.
    - Negation/immunity clauses (cannot be negated/destroyed, unaffected by...) verbatim.
    - Exact numeric limits — never round or vague.
    """
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
    
    // AI fields
    var summary: String = ""
    var isStreaming: Bool = true
    
    @ObservationIgnored
    var prompt: String {
        if let card {
            return """
                Card Name: \(card.cardName)
                Effect Text: \(card.cardEffect)
                Card Type: \(card.cardType)
                """
        } else {
            return ""
        }
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
            let res = await getCardScore(cardID: cardID)
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
