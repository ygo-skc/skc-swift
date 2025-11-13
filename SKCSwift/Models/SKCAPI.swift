//
//  SKCAPI.swift
//  SKCSwift
//
//  Created by Javi Gomez on 2/11/25.
//

import Foundation

/*
 Card models
 */

nonisolated struct MonsterAssociation: Codable, Equatable {
    let level: UInt8?
    let rank: UInt8?
    let scaleRating: UInt8?
    let linkRating: UInt8?
    let linkArrows: [String]?
    
    init(level: UInt8?, rank: UInt8?, scaleRating: UInt8?, linkRating: UInt8?, linkArrows: [String]?) {
        self.level = level
        self.rank = rank
        self.scaleRating = scaleRating
        self.linkRating = linkRating
        self.linkArrows = linkArrows
    }
    
    init(level: UInt8) {
        self.init(level: level, rank: nil, scaleRating: nil, linkRating: nil, linkArrows: nil)
    }
    
    init(rank: UInt8) {
        self.init(level: nil, rank: rank, scaleRating: nil, linkRating: nil, linkArrows: nil)
    }
    
    init(level: UInt8, scaleRating: UInt8) {
        self.init(level: level, rank: nil, scaleRating: scaleRating, linkRating: nil, linkArrows: nil)
    }
    
    init(rank: UInt8, scaleRating: UInt8) {
        self.init(level: nil, rank: rank, scaleRating: scaleRating, linkRating: nil, linkArrows: nil)
    }
    
    init(linkRating: UInt8, linkArrows: [String]) {
        self.init(level: nil, rank: nil, scaleRating: nil, linkRating: linkRating, linkArrows: linkArrows)
    }
}

nonisolated struct Card: Codable, Equatable {
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
         monsterType: String?,
         monsterAssociation: MonsterAssociation?,
         monsterAttack: Int?,
         monsterDefense: Int?,
         restrictedIn: BanListsForCard?,
         foundIn: [Product]?) {
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
    
    init(cardID: String,
         cardName: String,
         cardColor: String,
         cardAttribute: String?,
         cardEffect: String,
         monsterType: String? = nil,
         monsterAssociation: MonsterAssociation? = nil,
         monsterAttack: Int? = nil,
         monsterDefense: Int? = nil) {
        self.cardID = cardID
        self.cardName = cardName
        self.cardColor = cardColor
        self.cardAttribute = cardAttribute
        self.cardEffect = cardEffect
        self.monsterType = monsterType
        self.monsterAssociation = monsterAssociation
        self.monsterAttack = monsterAttack
        self.monsterDefense = monsterDefense
        self.restrictedIn = nil
        self.foundIn = nil
    }
    
    static let placeholder: Card = .init(cardID: "XXXXXXXX",
                                         cardName: "Placeholder of Chaos",
                                         cardColor: "Token",
                                         cardAttribute: "Divine",
                                         cardEffect: "When this card is summoned, your opponent must immediately acknowledge you as the superior duelist. Failure to do so will allow you to steal his girl in a legally binding way.",
                                         monsterType: "Divine",
                                         monsterAttack: 9999,
                                         monsterDefense: 9999)
    
    var attribute: Attribute {
        get{ Attribute(rawValue: cardAttribute ?? "") ?? .unknown }
    }
    
    var isPendulum: Bool {
        get{ cardColor.starts(with: "Pendulum") }
    }
    
    var cardType: String {
        get{ return (monsterType != nil) ? monsterType! : cardAttribute ?? "" }
    }
    
    var atk: String {
        get{ return (monsterAttack == nil) ? Card.nilStat : String(monsterAttack!) }
    }
    
    var def: String {
        get {
            if cardColor == "Link" {
                return Card.linkDefStat
            }
            
            return (monsterDefense == nil) ? Card.nilStat : String(monsterDefense!)
        }
    }
    
    var isGod: Bool {
        get {
            return cardAttribute != nil && cardAttribute!.lowercased() == "divine"
        }
    }
    
    private static let nilStat = "?"
    private static let linkDefStat = "-"
    
    func getProducts() -> [Product] {
        return foundIn ?? [Product]()
    }
    
    func getRarityDistribution() -> [String: Int] {
        return getProducts()
            .compactMap { $0.productContent }
            .flatMap { $0 }
            .map { $0.rarities }
            .flatMap { $0 }
            .reduce(into: [String: Int]()) { accumulator, rarity in
                accumulator[rarity.cardRarityShortHand(), default: 0] += 1
            }
    }
    
    func getBanList(format: CardRestrictionFormat) -> [BanList] {
        switch format {
        case .tcg:
            return restrictedIn?.TCG ?? []
        case .md:
            return restrictedIn?.MD ?? []
        default:
            return []
        }
    }
}

// used as convenience when working with NavigationDestination
struct CardLinkDestinationValue: Hashable {
    let cardID: String
    let cardName: String
}

nonisolated struct CardBrowseCriteria: Codable {
    let cardColors: [String]
    let attributes: [String]
    let monsterTypes: [String]
    let monsterSubTypes: [String]
    let levels: [UInt8]
    let ranks: [UInt8]
    let linkRatings: [UInt8]
}

nonisolated struct CardBrowseResults: Codable {
    let results: [Card]
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
    let numForbidden, numLimited, numSemiLimited, numLimitedOne, numLimitedTwo, numLimitedThree: UInt8
    let forbidden, limited, semiLimited: [Card]
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
         productTotal: Int?,
         productContent: [ProductContent]?) {
        self.productId = productId
        self.productLocale = productLocale
        self.productName = productName
        self.productType = productType
        self.productSubType = productSubType
        self.productReleaseDate = productReleaseDate
        self.productTotal = productTotal
        self.productContent = productContent
    }
    
    init(productId: String, productLocale: String, productName: String, productType: String, productSubType: String, productReleaseDate: String, productTotal: Int) {
        self.init(productId: productId, productLocale: productLocale, productName: productName, productType: productType,
                  productSubType: productSubType, productReleaseDate: productReleaseDate, productTotal: productTotal, productContent: [])
    }
    init(productId: String, productLocale: String, productName: String, productType: String, productSubType: String, productReleaseDate: String, productContent: [ProductContent]) {
        self.init(productId: productId, productLocale: productLocale, productName: productName, productType: productType,
                  productSubType: productSubType, productReleaseDate: productReleaseDate, productTotal: productContent.count, productContent: productContent)
    }
    
    var id: String {
        if !(productContent?.isEmpty ?? true), let productContent {
            return "\(productId)-\(productContent[0].id)"
        } else {
            return productId
        }
    }
}

struct ProductContent: Codable, Equatable, Identifiable {
    let card: Card?
    let productPosition: String
    let rarities: [String]
    
    init(card: Card?, productPosition: String, rarities: [String]) {
        self.card = card
        self.productPosition = productPosition
        self.rarities = rarities
    }
    
    init(productPosition: String, rarities: [String]) {
        self.init(card: nil, productPosition: productPosition, rarities: rarities)
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

// used as convenience when working with NavigationDestination
struct ProductLinkDestinationValue: Hashable {
    let productID: String
    let productName: String
}


/*
 Misc models
 */

struct SearchResults: Identifiable, Equatable {
    let id = UUID()
    let section: String
    let results: [Card]
}

struct SKCDatabaseStats: Codable, Equatable {
    let productTotal: Int
    let cardTotal: Int
    let banListTotal: Int
}
