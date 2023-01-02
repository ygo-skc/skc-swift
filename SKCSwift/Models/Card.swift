//
//  SKCCardInfoOutput.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import Foundation

struct MonsterAssociation: Codable {
    var level: Int?
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
}
