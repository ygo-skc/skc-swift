//
//  CardScore.swift
//  SKCSwift
//
//  Created by Javi Gomez on 10/25/25.
//

nonisolated struct CardScore: Codable, Equatable {
    let currentScoreByFormat: [String: UInt32]
    let uniqueFormats: [String]
    let scheduledChanges: [String]
}

extension CardScore {
    nonisolated static func rpcParser(currentScoreByFormat: [String: UInt32],
                                      uniqueFormats: [String],
                                      scheduledChanges: [String]) -> Self {
        return .init(currentScoreByFormat: currentScoreByFormat,
                     uniqueFormats: uniqueFormats,
                     scheduledChanges: scheduledChanges)
    }
}

nonisolated struct CardScores: Codable, Equatable {
    let entries: [CardScoreEntry]
}

nonisolated struct CardScoreEntry: Codable, Equatable {
    let card: Card
    let score: UInt32
}

extension CardScoreEntry {
    nonisolated static func rpcParser(cardID: String,
                                      cardName: String,
                                      cardColor: String,
                                      cardAttribute: String?,
                                      cardEffect: String,
                                      monsterType: String? = nil,
                                      monsterAttack: Int? = nil,
                                      monsterDefense: Int? = nil,
                                      score: UInt32) -> Self {
        return .init(card: Card(cardID: cardID,
                                cardName: cardName,
                                cardColor: cardColor,
                                cardAttribute: cardAttribute,
                                cardEffect: cardEffect),
                     score: score)
    }
}
