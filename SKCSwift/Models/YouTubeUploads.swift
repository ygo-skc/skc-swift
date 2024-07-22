//
//  YouTubeUploads.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/10/23.
//

struct YouTubeUploads: Codable {
    var videos: [YouTubeVideos]
    var total: Int
}

struct YouTubeVideos: Codable, Equatable {
    var id: String
    var title: String
    var description: String
    var publishedAt: String
    var thumbnailUrl: String
    var url: String
}
