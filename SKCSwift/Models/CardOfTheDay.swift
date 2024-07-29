//
//  CardOfTheDay.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

struct CardOfTheDay: Codable, Equatable {
    var date: String
    var version: Int
    var card: Card
}
