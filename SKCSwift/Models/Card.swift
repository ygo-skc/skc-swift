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
    let cardAttribute: String
    let cardEffect: String
    var monsterType: String?
    var monsterAssociation: MonsterAssociation?
    var monsterAttack: Int?
    var monsterDefense: Int?
    var restrictedIn: BanListsForCard?
    var foundIn: [Product]?
    
    private static let nilStat = "?"
    private static let linkDefStat = "-"
    
    func isPendulum() -> Bool {
        return cardColor.starts(with: "Pendulum")
    }
    
    func cardType() -> String {
        return (monsterType != nil) ? monsterType! : cardAttribute
    }
    
    func atk() -> String {
        return (monsterAttack == nil) ? Card.nilStat : String(monsterAttack!)
    }
    
    func def() -> String {
        if cardColor == "Link" {
            return Card.linkDefStat
        }
        
        return (monsterDefense == nil) ? Card.nilStat : String(monsterDefense!)
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
