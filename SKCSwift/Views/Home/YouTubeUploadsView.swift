//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct YouTubeUploadsView: View, Equatable {
    static func == (lhs: YouTubeUploadsView, rhs: YouTubeUploadsView) -> Bool {
        lhs.ytUploads == rhs.ytUploads
        && lhs.dataTaskStatus == rhs.dataTaskStatus
    }
    
    let ytUploads: [YouTubeVideos]
    let dataTaskStatus: DataTaskStatus
    let networkError: NetworkError?
    let retryCB: () async -> Void
    
    @ViewBuilder
    private var youtubeUploads: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Did you know I make YouTube videos? Keep tabs on the TCG, watch the best un-boxings on YouTube or watch some dope Master Duel replays. Don't forget to sub.")
                .font(.callout)
            
            ForEach(ytUploads, id: \.id) { video in
                YouTubeUploadView(videoID: video.id, title: video.title, uploadUrl: video.url)
                    .equatable()
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("YouTube videos")
                .modifier(.headerText)
            if let networkError {
                NetworkErrorView(error: networkError, action: { Task { await retryCB() } })
            } else if dataTaskStatus == .done || !ytUploads.isEmpty {
                youtubeUploads
            } else {
                HStack {
                    ProgressView("Loading…")
                        .controlSize(.large)
                }
                .padding(.top)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct YouTubeUploadView: View, Equatable {
    static func == (lhs: YouTubeUploadView, rhs: YouTubeUploadView) -> Bool {
        lhs.videoTitle == rhs.videoTitle
        && lhs.videoURI == rhs.videoURI
    }

    let videoTitle: String
    let videoURI: String

    @Environment(\.openURL) private var openURL
    private var videoThumbnailUrl: URL

    init(videoID: String, title: String, uploadUrl: String) {
        self.videoTitle = title
        self.videoURI = uploadUrl
        
        self.videoThumbnailUrl = URL(string: "https://img.youtube.com/vi/\(videoID)/mqdefault.jpg")!
    }

    private static let UPLOAD_IMG_WIDTH: CGFloat = 175
    private static let UPLOAD_IMG_HEIGHT: CGFloat = YouTubeUploadView.UPLOAD_IMG_WIDTH * 0.6
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 15)  {
                RoundedRectImage(width: YouTubeUploadView.UPLOAD_IMG_WIDTH, height: YouTubeUploadView.UPLOAD_IMG_HEIGHT, imageUrl: videoThumbnailUrl, cornerRadius: 8)
                    .equatable()
                Text(videoTitle)
                    .font(.subheadline)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if let url = URL(string: videoURI) {
                    openURL(url)
                }
            }
            Divider()
        }
        .buttonStyle(.plain)
    }
}

#Preview("Default") {
    YouTubeUploadsView(ytUploads: [],
                       dataTaskStatus: .done,
                       networkError: nil,
                       retryCB: {})
    .padding(.horizontal)
}

#Preview("Loading") {
    YouTubeUploadsView(ytUploads: [],
                       dataTaskStatus: .pending,
                       networkError: nil,
                       retryCB: {})
    .padding(.horizontal)
}

#Preview("Network Error") {
    YouTubeUploadsView(ytUploads: [],
                       dataTaskStatus: .error,
                       networkError: .timeout,
                       retryCB: {})
    .padding(.horizontal)
}

