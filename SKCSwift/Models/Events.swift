//
//  SKCDatabaseStats.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/27/23.
//

import Foundation

struct Events: Codable {
    var service: String
    var events: [Event]
}

struct Event: Codable {
    var name: String
    var notes: String
    var location: String
    var eventDate: String
    var url: String
}
