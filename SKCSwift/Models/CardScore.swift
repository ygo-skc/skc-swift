//
//  CardScore.swift
//  SKCSwift
//
//  Created by Javi Gomez on 10/25/25.
//
import SwiftProtobuf

nonisolated struct CardScore: Codable, Equatable {
    let currentScoreByFormat: [String: UInt32]
    let uniqueFormats: [String]
    let scheduledChanges: [String]
}

nonisolated struct CardScores: Codable, Equatable {
    let format, effectiveDate: String
    let entries: [CardScoreEntry]
    let totalEntries: UInt32
}

nonisolated struct CardScoreEntry: Codable, Equatable {
    let card: YGOCard
    let score: UInt32
    
    init(from: Ygo_CardScoreEntry) {
        let card = from.card
        self.card = YGOCard(cardID: card.id,
                            cardName: card.name,
                            cardColor: card.color,
                            cardAttribute: card.attribute,
                            cardEffect: card.effect,
                            monsterType: (card.hasMonsterType) ?  card.monsterType.value : nil,
                            monsterAttack: (card.hasAttack) ? card.attack.value : nil,
                            monsterDefense: (card.hasDefense) ? card.defense.value : nil)
        self.score = from.score
    }
}
