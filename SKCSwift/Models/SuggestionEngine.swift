//
//  CardSuggestions.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/22/23.
//

struct CardReference: Codable, Equatable {
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
    
    var hasSuggestions: Bool {
        if suggestions.namedMaterials.isEmpty && suggestions.namedReferences.isEmpty
            && support.referencedBy.isEmpty && support.materialFor.isEmpty {
            return false
        }
        return true
    }
}

struct TrendingMetric<R:Codable & Equatable>: Codable, Equatable {
    let resource: R
    let occurrences: Int
    let change: Int
}

struct Trending<R:Codable & Equatable>: Codable, Equatable {
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

nonisolated struct BatchCardRequest: Codable {
    let cardIDs: Set<String>
}

nonisolated struct CardDetailsResponse: Codable {
    let cardInfo: [String: Card]
    let unknownResources: [String]
}

struct BatchSuggestions: Codable {
    let namedMaterials: [CardReference]
    let namedReferences: [CardReference]
    let materialArchetypes: Set<String>
    let referencedArchetypes: Set<String>
    let unknownResources: Set<String>
    let falsePositives: Set<String>
}

struct BatchSupport: Codable {
    let referencedBy: [CardReference]
    let materialFor: [CardReference]
    let unknownResources: Set<String>
    let falsePositives: Set<String>
}

struct ArchetypeData: Codable {
    let usingName: [Card]
    let usingText: [Card]
    let exclusions: [Card]
}

struct ArchetypeLinkDestinationValue: Hashable {
    let archetype: String
}
