//
//  SKCDatabaseStats.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/27/23.
//

class SKCDatabaseStats: Codable, Equatable {
    static func == (lhs: SKCDatabaseStats, rhs: SKCDatabaseStats) -> Bool {
        lhs.productTotal == rhs.productTotal && lhs.banListTotal == rhs.banListTotal && lhs.cardTotal == rhs.cardTotal
    }
    
    let productTotal: Int
    let cardTotal: Int
    let banListTotal: Int
    
    init(productTotal: Int, cardTotal: Int, banListTotal: Int) {
        self.productTotal = productTotal
        self.cardTotal = cardTotal
        self.banListTotal = banListTotal
    }
}
