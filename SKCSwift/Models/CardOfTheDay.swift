//
//  CardOfTheDay.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/25/23.
//

import Foundation

struct CardOfTheDay: Codable {
    var date: String
    var version: Int
    var card: Card
}
