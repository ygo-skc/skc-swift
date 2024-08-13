//
//  CardOfTheDay.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

class CardOfTheDay: Codable, Equatable {
    static func == (lhs: CardOfTheDay, rhs: CardOfTheDay) -> Bool {
        lhs.date == rhs.date && lhs.card.cardID == rhs.card.cardID
    }
    
    let date: String
    let version: UInt8
    let card: Card
    
    init(date: String, version: UInt8, card: Card) {
        self.date = date
        self.version = version
        self.card = card
    }
}
