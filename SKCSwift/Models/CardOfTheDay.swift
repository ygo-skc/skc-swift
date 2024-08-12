//
//  CardOfTheDay.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

struct CardOfTheDay: Codable, Equatable {
    let date: String
    let version: UInt8
    let card: Card
}
