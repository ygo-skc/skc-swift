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
    let card: Card
    let hasSelfReference: Bool
    let namedMaterials: [CardReference]
    let namedReferences: [CardReference]
    let materialArchetypes: [String]
    let referencedArchetypes: [String]
}

struct CardSupport: Codable {
    let card: Card
    let referencedBy: [CardReference]
    let materialFor: [CardReference]
}
