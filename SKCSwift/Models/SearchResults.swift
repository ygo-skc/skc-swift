//
//  SearchResults.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/8/23.
//

import Foundation

struct SearchResults: Identifiable {
    let id = UUID()
    let section: String
    let results: [Card]
}
