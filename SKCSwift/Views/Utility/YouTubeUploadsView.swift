//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct YouTubeUploadsView: View, Equatable {
    let videos: [YouTubeVideos]?
    
    var body: some View {
        SectionView(header: "YouTube videos",
                    variant: .plain,
                    content: {
            if let videos {
                Text("Did you know I make YouTube videos? Keep tabs on the TCG, watch the best un-boxings on YouTube or watch some dope Master Duel replays. Don't forget to sub.")
                    .font(.body)
                
                LazyVStack(alignment: .leading, spacing: 5) {
                    ForEach(videos, id: \.id) { video in
                        YouTubeUploadView(videoID: video.id, title: video.title, uploadUrl: video.url)
                            .equatable()
                    }
                }
                .frame(maxWidth: .infinity)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        })
    }
}

private struct YouTubeUploadView: View, Equatable {
    let videoTitle: String
    let videoURI: String
    
    private var videoThumbnailUrl: URL
    
    init(videoID: String, title: String, uploadUrl: String) {
        self.videoTitle = title
        self.videoURI = uploadUrl
        
        self.videoThumbnailUrl = URL(string: String(format: YouTubeUploadView.THUMBNAIL_URI_TEMPLATE, videoID))!
    }
    
    private static let UPLOAD_IMG_WIDTH: CGFloat = 175
    private static let UPLOAD_IMG_HEIGHT: CGFloat = YouTubeUploadView.UPLOAD_IMG_WIDTH * 0.6
    private static let THUMBNAIL_URI_TEMPLATE = "https://img.youtube.com/vi/%@/mqdefault.jpg"
    
    var body: some View {
        VStack {
            HStack(spacing: 15)  {
                RoundedRectImage(width: YouTubeUploadView.UPLOAD_IMG_WIDTH, height: YouTubeUploadView.UPLOAD_IMG_HEIGHT, imageUrl: videoThumbnailUrl, cornerRadius: 8)
                    .equatable()
                VStack(alignment: .leading, spacing: 5) {
                    Text(videoTitle)
                        .font(.callout)
                        .fontWeight(.regular)
                }
                .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                if let url = URL(string: videoURI) {
                    UIApplication.shared.open(url)
                }
            }
            Divider()
                .padding(.vertical, 2)
        }
        .frame(height: YouTubeUploadView.UPLOAD_IMG_HEIGHT + 12)
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
    }
}

#Preview() {
    YouTubeUploadsView(videos: nil)
}

#Preview() {
    YouTubeUploadsView(videos: [YouTubeVideos(id: "z7VKxpoAJjA", title: "Best Opening EVAR!", description: "This is the best opening ever!",
                                              publishedAt: "2024-08-23T05:00:00.000Z", thumbnailUrl: "", url: "https://www.youtube.com/watch?v=z7VKxpoAJjA")])
}
