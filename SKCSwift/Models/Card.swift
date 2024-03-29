//
//  SKCCardInfoOutput.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

struct MonsterAssociation: Codable {
    var level: Int?
    var rank: Int?
    var scaleRating: Int?
    var linkRating: Int?
    var linkArrows: [String]?
}

struct Card: Codable {
    var cardID: String
    var cardName: String
    var cardColor: String
    var cardAttribute: String
    var cardEffect: String
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
struct CardValue: Hashable {
    var cardID: String
    var cardName: String
}
