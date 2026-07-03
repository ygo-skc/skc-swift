//
//  YouTubeUploads.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/10/23.
//

nonisolated struct YouTubeUploads: Codable {
    let videos: [YouTubeVideos]
    let total: Int
}

nonisolated struct YouTubeVideos: Codable, Equatable {
    static func == (lhs: YouTubeVideos, rhs: YouTubeVideos) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let title: String
    let description: String
    let publishedAt: String
    let thumbnailUrl: String
    let url: String
}

nonisolated struct Events: Codable {
    let service: String
    let events: [Event]
}

nonisolated struct Event: Codable, Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.name == rhs.name && lhs.eventDate == rhs.eventDate && lhs.url == rhs.url
    }
    
    let name: String
    let notes: String
    let location: String
    let eventDate: String
    let url: String
}
