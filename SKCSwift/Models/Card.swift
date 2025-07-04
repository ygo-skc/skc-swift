//
//  SKCCardInfoOutput.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

struct MonsterAssociation: Codable, Equatable {
    let level: UInt8?
    let rank: UInt8?
    let scaleRating: UInt8?
    let linkRating: UInt8?
    let linkArrows: [String]?
}

extension MonsterAssociation {
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

struct Card: Codable, Equatable {
    let cardID: String
    let cardName: String
    let cardColor: String
    let cardAttribute: String?
    let cardEffect: String
    var monsterType: String?
    var monsterAssociation: MonsterAssociation?
    var monsterAttack: Int?
    var monsterDefense: Int?
    var restrictedIn: BanListsForCard?
    var foundIn: [Product]?
    
    nonisolated var attribute: Attribute {
        get{ Attribute(rawValue: cardAttribute ?? "") ?? .unknown }
    }
    
    nonisolated var isPendulum: Bool {
        get{ cardColor.starts(with: "Pendulum") }
    }
    
    nonisolated var cardType: String {
        get{ return (monsterType != nil) ? monsterType! : cardAttribute ?? "" }
    }
    
    nonisolated var atk: String {
        get{ return (monsterAttack == nil) ? Card.nilStat : String(monsterAttack!) }
    }
    
    nonisolated var def: String {
        get {
            if cardColor == "Link" {
                return Card.linkDefStat
            }
            
            return (monsterDefense == nil) ? Card.nilStat : String(monsterDefense!)
        }
    }
    
    nonisolated var isGod: Bool {
        get {
            return cardAttribute != nil && cardAttribute!.lowercased() == "divine"
        }
    }
    
    private static let nilStat = "?"
    private static let linkDefStat = "-"
    
    nonisolated func getProducts() -> [Product] {
        return foundIn ?? [Product]()
    }
    
    nonisolated func getRarityDistribution() -> [String: Int] {
        return getProducts()
            .compactMap { $0.productContent }
            .flatMap { $0 }
            .map { $0.rarities }
            .flatMap { $0 }
            .reduce(into: [String: Int]()) { accumulator, rarity in
                accumulator[rarity.cardRarityShortHand(), default: 0] += 1
            }
    }
    
    nonisolated func getBanList(format: BanListFormat) -> [BanList] {
        switch format {
        case .tcg:
            return restrictedIn?.TCG ?? [BanList]()
        case .md:
            return restrictedIn?.MD ?? [BanList]()
        }
    }
}

// used as convenience when working with NavigationDestination
struct CardLinkDestinationValue: Hashable {
    let cardID: String
    let cardName: String
}

struct CardBrowseCriteria: Codable {
    let cardColors: [String]
    let attributes: [String]
    let monsterTypes: [String]
    let monsterSubTypes: [String]
    let levels: [UInt8]
    let ranks: [UInt8]
    let linkRatings: [UInt8]
}

struct CardBrowseResults: Codable {
    let results: [Card]
    let numResults: UInt
}
