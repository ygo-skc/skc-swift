//
//  SKCCardInfoOutput.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

struct MonsterAssociation: Codable, Equatable {
    let level: Int?
    let rank: Int?
    let scaleRating: Int?
    let linkRating: Int?
    let linkArrows: [String]?
}

extension MonsterAssociation {
    init(level: Int) {
        self.init(level: level, rank: nil, scaleRating: nil, linkRating: nil, linkArrows: nil)
    }
    
    init(rank: Int) {
        self.init(level: nil, rank: rank, scaleRating: nil, linkRating: nil, linkArrows: nil)
    }
    
    init(level: Int, scaleRating: Int) {
        self.init(level: level, rank: nil, scaleRating: scaleRating, linkRating: nil, linkArrows: nil)
    }
    
    init(rank: Int, scaleRating: Int) {
        self.init(level: nil, rank: rank, scaleRating: scaleRating, linkRating: nil, linkArrows: nil)
    }
    
    init(linkRating: Int, linkArrows: [String]) {
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
