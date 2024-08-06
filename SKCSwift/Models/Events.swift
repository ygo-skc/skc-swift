//
//  SKCDatabaseStats.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/27/23.
//

struct Events: Codable {
    let service: String
    let events: [Event]
}

struct Event: Codable, Equatable {
    let name: String
    let notes: String
    let location: String
    let eventDate: String
    let url: String
}
