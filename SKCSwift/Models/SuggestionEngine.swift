//
//  CardSuggestions.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/22/23.
//

struct CardReference: Codable {
    let occurrences: Int
    let card: Card
}

struct CardSuggestions: Codable {
    let card: Card?
    let hasSelfReference: Bool?
    let namedMaterials: [CardReference]
    let namedReferences: [CardReference]
    let materialArchetypes: [String]
    let referencedArchetypes: [String]
}

struct CardSupport: Codable {
    let card: Card?
    let referencedBy: [CardReference]
    let materialFor: [CardReference]
}

struct ProductSuggestions: Codable {
    let suggestions: CardSuggestions
    let support: CardSupport
}

struct TrendingMetric<R:Codable>: Codable {
    let resource: R
    let occurrences: Int
    let change: Int
}

struct Trending<R:Codable>: Codable {
    let resourceName: TrendingResourceType
    let metrics: [TrendingMetric<R>]
}

struct CardOfTheDay: Codable, Equatable {
    static func == (lhs: CardOfTheDay, rhs: CardOfTheDay) -> Bool {
        lhs.date == rhs.date && lhs.card.cardID == rhs.card.cardID
    }
    
    let date: String
    let version: UInt8
    let card: Card
}

struct CardDetailsRequest: Codable {
    let cardIDs: [String]
}

struct CardDetailsResponse: Codable {
    let cardInfo: [String: Card]
    let unknownResources: [String]
}
