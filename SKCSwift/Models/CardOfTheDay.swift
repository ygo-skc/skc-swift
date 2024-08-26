//
//  CardOfTheDay.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

struct CardOfTheDay: Codable, Equatable {
    static func == (lhs: CardOfTheDay, rhs: CardOfTheDay) -> Bool {
        lhs.date == rhs.date && lhs.card.cardID == rhs.card.cardID
    }
    
    let date: String
    let version: UInt8
    let card: Card
}
