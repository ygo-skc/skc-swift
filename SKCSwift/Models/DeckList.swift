//
//  DeckList.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/22/23.
//

import Foundation

struct DeckContent: Codable {
    var quantity: Int
    var card: Card
}

struct DeckList: Codable {
    var id: String
    var name: String
    var listContent: String
    var videoUrl: String?   // this needs to be changed in api as it has an uppercase in spec
    var uniqueCards: Int?
    var deckMascots: [String]?
    var numMainDeckCards: Int?
    var numExtraDeckCards: Int?
    var tags: [String]?
    var createdAt: String
    var updatedAt: String
    var mainDeck: [DeckContent]?
    var extraDeck: [DeckContent]?
}
