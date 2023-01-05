//
//  SKCCardInfoOutput.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import Foundation

enum Attribute: String {
    case dark = "Dark", light = "Light", earth = "Earth", wind = "Wind", water = "Water", fire = "Fire"
}

struct MonsterAssociation: Codable {
    var level: Int?
    var rank: Int?
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
}
