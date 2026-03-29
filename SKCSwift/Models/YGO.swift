//
//  SKCAPI.swift
//  SKCSwift
//
//  Created by Javi Gomez on 2/11/25.
//

import Foundation

nonisolated struct MonsterAssociation: Codable, Equatable, Hashable {
    let level, rank, scaleRating, linkRating: UInt8?
    let linkArrows: [String]?
    
    init(level: UInt8? = nil, rank: UInt8? = nil, scaleRating: UInt8? = nil, linkRating: UInt8? = nil, linkArrows: [String]? = nil) {
        self.level = level
        self.rank = rank
        self.scaleRating = scaleRating
        self.linkRating = linkRating
        self.linkArrows = linkArrows
    }
}

nonisolated struct YGOCard: Codable, Equatable, Hashable {
    let cardID, cardName, cardColor, cardEffect: String
    let cardAttribute, qualifier: String?
    private let monsterType: String?
    let monsterAssociation: MonsterAssociation?
    private let monsterAttack: UInt32?
    private let monsterDefense: UInt32?
    
    init(cardID: String,
         cardName: String,
         cardColor: String,
         cardAttribute: String?,
         cardEffect: String,
         monsterType: String? = nil,
         monsterAssociation: MonsterAssociation? = nil,
         monsterAttack: UInt32? = nil,
         monsterDefense: UInt32? = nil,
         qualifier: String? = "") {
        self.cardID = cardID
        self.cardName = cardName
        self.cardColor = cardColor
        self.cardAttribute = cardAttribute
        self.cardEffect = cardEffect
        self.monsterType = monsterType
        self.monsterAssociation = monsterAssociation
        self.monsterAttack = monsterAttack
        self.monsterDefense = monsterDefense
        self.qualifier = qualifier == nil ? "" : qualifier!
    }
    
    func withQualifier(qualifier: String) -> YGOCard {
        .init(
            cardID: cardID,
            cardName: cardName,
            cardColor: cardColor,
            cardAttribute: cardAttribute,
            cardEffect: cardEffect,
            monsterType: monsterType,
            monsterAssociation: monsterAssociation,
            monsterAttack: monsterAttack,
            monsterDefense: monsterDefense,
            qualifier: qualifier)
    }
    
    /// this ID attribute can be customized to avoid List key issues in case List has multiple cards w/ same ID
    var id: String {
        cardID + (qualifier == nil ? "" : qualifier!)
    }
    
    var attribute: Attribute {
        Attribute(rawValue: cardAttribute ?? "") ?? .unknown
    }
    
    var isPendulum: Bool {
        cardColor.starts(with: "Pendulum")
    }
    
    var cardType: String {
        (monsterType != nil) ? monsterType! : cardAttribute ?? ""
    }
    
    var monsterTypeE: MonsterType {
        (monsterType != nil) ? MonsterType(rawValue: String(monsterType?.split(separator: "/").first ?? "")) ?? .unknown : .unknown
    }
    
    var atk: String {
        (monsterAttack == nil) ? YGOCard.nilStat.description : String(monsterAttack!)
    }
    
    var def: String {
        if cardColor == "Link" {
            return YGOCard.linkDefStat.description
        }
        return (monsterDefense == nil) ? YGOCard.nilStat.description : String(monsterDefense!)
    }
    
    var isGod: Bool {
        cardAttribute != nil && cardAttribute!.lowercased() == "divine"
    }
    
    static let placeholder: YGOCard = .init(cardID: "XXXXXXXX",
                                            cardName: "Placeholder of Chaos",
                                            cardColor: "Token",
                                            cardAttribute: "Divine",
                                            cardEffect: "When this card is summoned, your opponent must immediately acknowledge you as the superior duelist. Failure to do so will allow you to steal his girl in a legally binding way.",
                                            monsterType: "Divine",
                                            monsterAttack: 9999,
                                            monsterDefense: 9999)
    fileprivate static let nilStat: StaticString = "?"
    fileprivate static let linkDefStat: StaticString = "-"
}

nonisolated struct CardBrowseCriteria: Codable {
    let cardColors, attributes, monsterTypes, monsterSubTypes: [String]
    let levels, ranks, linkRatings: [UInt8]
}

nonisolated struct CardBrowseResults: Codable {
    let results: [YGOCard]
    let numResults: UInt
}

/*
 Ban List models
 */

nonisolated struct BanList: Codable, Equatable {
    let banListDate, cardID, banStatus, format: String
}

nonisolated struct BanListsForCard: Codable, Equatable {
    let TCG, MD: [BanList]?
}

nonisolated struct BanListDates: Codable, Hashable {
    let banListDates: [BanListDate]
}

nonisolated struct BanListDate: Codable, Hashable {
    let effectiveDate: String
}

nonisolated struct BannedContent: Codable, Equatable {
    let forbidden, limited, semiLimited: [YGOCard]
    let numForbidden, numLimited, numSemiLimited, numLimitedOne, numLimitedTwo, numLimitedThree: UInt16
}

nonisolated struct BanListNewContent: Codable {
    let listRequested, comparedTo: String
    let forbidden, limited, semiLimited: [BanListChange]
    let numForbidden, numLimited, numSemiLimited: UInt8
    
    enum CodingKeys: String, CodingKey {
        case listRequested
        case comparedTo
        case forbidden = "newForbidden"
        case limited = "newLimited"
        case semiLimited = "newSemiLimited"
        case numForbidden = "numNewForbidden"
        case numLimited = "numNewLimited"
        case numSemiLimited = "numNewSemiLimited"
    }
}

nonisolated struct BanListRemovedContent: Codable {
    let listRequested, comparedTo: String
    let changes: [BanListChange]
    let numRemoved: UInt8
    
    enum CodingKeys: String, CodingKey {
        case listRequested
        case comparedTo
        case changes = "removedContent"
        case numRemoved
    }
}

nonisolated struct BanListChange: Codable {
    let card: YGOCard
    let previousBanStatus: String
}


/*
 Product models
 */

struct Product: Codable, Equatable, Identifiable {
    let productId, productLocale, productName, productType, productSubType, productReleaseDate: String
    let productTotal: Int?
    let productContent: [ProductContent]?
    
    init(productId: String,
         productLocale: String,
         productName: String,
         productType: String,
         productSubType: String,
         productReleaseDate: String,
         productTotal: Int? = nil,
         productContent: [ProductContent]? = nil) {
        self.productId = productId
        self.productLocale = productLocale
        self.productName = productName
        self.productType = productType
        self.productSubType = productSubType
        self.productReleaseDate = productReleaseDate
        self.productTotal = productTotal
        self.productContent = productContent
    }
    
    var id: String {
        if !(productContent?.isEmpty ?? true), let productContent {
            return "\(productId)-\(productContent[0].id)"
        } else {
            return productId
        }
    }
}

extension Array where Element == Product {
    func rarityDistribution() -> [String: Int] {
        return self.lazy
            .compactMap { $0.productContent }
            .flatMap { $0 }
            .map { $0.rarities }
            .flatMap { $0 }
            .reduce(into: [String: Int]()) { accumulator, rarity in
                accumulator[rarity.cardRarityShortHand(), default: 0] += 1
            }
    }
}

struct ProductContent: Codable, Equatable, Identifiable {
    let card: YGOCard?
    let productPosition: String
    let rarities: [String]
    
    init(card: YGOCard? = nil, productPosition: String, rarities: [String]) {
        self.card = card
        self.productPosition = productPosition
        self.rarities = rarities
    }
    
    var id: String {
        if let card {
            return card.cardID + productPosition + String(rarities.hashValue)
        } else {
            return productPosition + String(rarities.hashValue)
        }
    }
}

struct Products: Codable, Equatable {
    let locale: String
    let products: [Product]
}

/*
 Misc models
 */

struct SearchResults: Identifiable, Equatable {
    let id = UUID()
    let section: String
    let results: [YGOCard]
}

struct SKCDatabaseStats: Codable, Equatable {
    let productTotal, cardTotal, banListTotal: Int
}

/*
 Suggestions
 */

struct CardReference: Codable, Equatable {
    let card: YGOCard
    let occurrences: Int
}

struct CardSuggestions: Codable {
    let card: YGOCard
    let namedMaterials, namedReferences: [CardReference]
    let materialArchetypes, referencedArchetypes: [String]
    let hasSelfReference: Bool
}

struct CardSupport: Codable {
    let card: YGOCard?
    let referencedBy, materialFor: [CardReference]
}

struct ProductSuggestions: Codable {
    let suggestions: CardSuggestions
    let support: CardSupport
    
    var hasSuggestions: Bool {
        if suggestions.namedMaterials.isEmpty && suggestions.namedReferences.isEmpty
            && support.referencedBy.isEmpty && support.materialFor.isEmpty {
            return false
        }
        return true
    }
}

struct TrendingMetric<R:Codable & Equatable>: Codable, Equatable {
    let resource: R
    let occurrences, change: Int
}

struct Trending<R:Codable & Equatable>: Codable, Equatable {
    let resourceName: TrendingResourceType
    let metrics: [TrendingMetric<R>]
}

struct CardOfTheDay: Codable, Equatable {
    static func == (lhs: CardOfTheDay, rhs: CardOfTheDay) -> Bool {
        lhs.date == rhs.date && lhs.card.cardID == rhs.card.cardID
    }
    
    let date: String
    let card: YGOCard
    let version: UInt8
}

nonisolated struct BatchCardRequest: Codable {
    let cardIDs: Set<String>
}

nonisolated struct CardDetailsResponse: Codable {
    let cardInfo: [String: YGOCard]
    let unknownResources: [String]
}

struct BatchSuggestions: Codable {
    let namedMaterials, namedReferences: [CardReference]
    let materialArchetypes, referencedArchetypes, unknownResources, falsePositives: Set<String>
}

struct BatchSupport: Codable {
    let referencedBy, materialFor: [CardReference]
    let unknownResources, falsePositives: Set<String>
}

struct YGOArchetypeData: Codable {
    let usingName, usingText, exclusions: [YGOCard]
}

/*
 Link destination types
 */

struct ProductLinkDestinationValue: Hashable {
    let productID, productName: String
}

struct CardLinkDestinationValue: Hashable {
    let cardID, cardName: String
}

struct YGOArchetypeLinkDestinationValue: Hashable {
    let archetype: String
}

struct YGOArchetypeCategoryLinkDestinationValue: Hashable {
    let archetype: String
    let category: YGOArchetypeCategory
    let cards: [YGOCard]
}

struct RestrictedContentChangesLinkDestinationValue: Hashable {
    let effectiveDate: String
    let format: CardRestrictionFormat
}
