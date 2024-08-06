//
//  YouTubeUploads.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/10/23.
//

struct YouTubeUploads: Codable {
    let videos: [YouTubeVideos]
    let total: Int
}

struct YouTubeVideos: Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let publishedAt: String
    let thumbnailUrl: String
    let url: String
}
