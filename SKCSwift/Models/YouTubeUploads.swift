//
//  YouTubeUploads.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/10/23.
//

class YouTubeUploads: Codable {
    let videos: [YouTubeVideos]
    let total: Int
    
    init(videos: [YouTubeVideos], total: Int) {
        self.videos = videos
        self.total = total
    }
}

class YouTubeVideos: Codable, Equatable {
    static func == (lhs: YouTubeVideos, rhs: YouTubeVideos) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let title: String
    let description: String
    let publishedAt: String
    let thumbnailUrl: String
    let url: String
    
    init(id: String, title: String, description: String, publishedAt: String, thumbnailUrl: String, url: String) {
        self.id = id
        self.title = title
        self.description = description
        self.publishedAt = publishedAt
        self.thumbnailUrl = thumbnailUrl
        self.url = url
    }
}
