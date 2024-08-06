//
//  DeckList.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/22/23.
//

struct DeckContent: Codable {
    let quantity: Int
    let card: Card
}

struct DeckList: Codable {
    let id: String
    let name: String
    let listContent: String
    let videoUrl: String
    let uniqueCards: [String]
    let deckMascots: [String]
    let numMainDeckCards: Int
    let numExtraDeckCards: Int
    let tags: [String]
    let createdAt: String
    let updatedAt: String
    let mainDeck: [DeckContent]?
    let extraDeck: [DeckContent]?
}
