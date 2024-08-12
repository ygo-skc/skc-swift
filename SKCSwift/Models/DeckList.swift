//
//  DeckList.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/22/23.
//

struct DeckContent: Codable {
    let quantity: UInt8
    let card: Card
}

struct DeckList: Codable {
    let id: String
    let name: String
    let listContent: String
    let videoUrl: String
    let uniqueCards: [String]
    let deckMascots: [String]
    let numMainDeckCards: UInt8
    let numExtraDeckCards: UInt8
    let tags: [String]
    let createdAt: String
    let updatedAt: String
    let mainDeck: [DeckContent]?
    let extraDeck: [DeckContent]?
}
