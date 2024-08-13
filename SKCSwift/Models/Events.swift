//
//  SKCDatabaseStats.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/27/23.
//

class Events: Codable {
    let service: String
    let events: [Event]
    
    init(service: String, events: [Event]) {
        self.service = service
        self.events = events
    }
}

class Event: Codable, Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.name == rhs.name && lhs.eventDate == rhs.eventDate && lhs.url == rhs.url
    }
    
    let name: String
    let notes: String
    let location: String
    let eventDate: String
    let url: String
    
    init(name: String, notes: String, location: String, eventDate: String, url: String) {
        self.name = name
        self.notes = notes
        self.location = location
        self.eventDate = eventDate
        self.url = url
    }
}
