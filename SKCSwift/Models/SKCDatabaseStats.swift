//
//  SKCDatabaseStats.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/27/23.
//

struct SKCDatabaseStats: Codable, Equatable {
    static func == (lhs: SKCDatabaseStats, rhs: SKCDatabaseStats) -> Bool {
        lhs.productTotal == rhs.productTotal && lhs.banListTotal == rhs.banListTotal && lhs.cardTotal == rhs.cardTotal
    }
    
    let productTotal: Int
    let cardTotal: Int
    let banListTotal: Int
}
