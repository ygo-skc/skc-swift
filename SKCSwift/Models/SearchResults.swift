//
//  SearchResults.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/8/23.
//

import Foundation

struct SearchResults: Identifiable {
    var id = UUID()
    var section: String
    var results: [Card]
}
