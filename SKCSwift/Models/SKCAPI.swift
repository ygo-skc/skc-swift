//
//  SKCAPI.swift
//  SKCSwift
//
//  Created by Javi Gomez on 2/11/25.
//

import Foundation

struct SearchResults: Identifiable, Equatable {
    let id = UUID()
    let section: String
    let results: [Card]
}

struct SKCDatabaseStats: Codable, Equatable {
    let productTotal: Int
    let cardTotal: Int
    let banListTotal: Int
}
