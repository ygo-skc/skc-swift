//
//  Text.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/18/23.
//

import Foundation

func replaceHTMLEntities(subject: String) -> String {
    return subject
        .replacingOccurrences(of: "&bull;", with: "•")
}

extension String {
    func cardRarityShortHand() -> String {
        switch self.lowercased() {
        case "ultimate rare":
            return "Ulti"
        case "quarter century ultra rare":
            return "QCR Ultra"
        case "quarter century secret rare":
            return "QCR Secret"
        case "pharaoh's rare - ultra rare":
            return "Ultra Pharaoh's Rare"
        case "pharaoh's rare - secret rare":
            return "Secret Pharaoh's Rare"
        default:
            return self
        }
    }
}
