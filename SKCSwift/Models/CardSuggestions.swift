//
//  CardSuggestions.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/22/23.
//

struct CardReference: Codable {
    var occurrences: Int
    var card: Card
}

struct CardSuggestions: Codable {
    var card: Card
    var hasSelfReference: Bool
    var namedMaterials: [CardReference]
    var namedReferences: [CardReference]
    var materialArchetypes: [String]
    var referencedArchetypes: [String]
}

struct CardSupport: Codable {
    var card: Card
    var referencedBy: [CardReference]
    var materialFor: [CardReference]
}
