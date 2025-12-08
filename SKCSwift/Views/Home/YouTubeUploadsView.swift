//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct YouTubeUploadsView: View, Equatable {
    static func == (lhs: YouTubeUploadsView, rhs: YouTubeUploadsView) -> Bool {
        lhs.ytUplaods == rhs.ytUplaods && lhs.dataTaskStatus == rhs.dataTaskStatus && lhs.networkError == rhs.networkError
    }
    
    let ytUplaods: [YouTubeVideos]
    let dataTaskStatus: DataTaskStatus
    let networkError: NetworkError?
    let retryCB: () async -> Void
    
    var body: some View {
        SectionView(header: "YouTube videos",
                    variant: .plain,
                    content: {
            VStack {
                if let networkError {
                    NetworkErrorView(error: networkError, action: { Task { await retryCB() } })
                } else {
                    if dataTaskStatus == .done || !ytUplaods.isEmpty {
                        YouTubeUploadsContentView(ytUplaods: ytUplaods)
                    } else {
                        ProgressView("Loading...")
                            .controlSize(.large)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        })
    }
    
    private struct YouTubeUploadsContentView: View {
        let ytUplaods: [YouTubeVideos]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text("Did you know I make YouTube videos? Keep tabs on the TCG, watch the best un-boxings on YouTube or watch some dope Master Duel replays. Don't forget to sub.")
                    .font(.callout)
                
                ForEach(ytUplaods, id: \.id) { video in
                    YouTubeUploadView(videoID: video.id, title: video.title, uploadUrl: video.url)
                        .equatable()
                }
            }
            .frame(maxWidth: .infinity)
        }
        
        private struct YouTubeUploadView: View, Equatable {
            let videoTitle: String
            let videoURI: String
            
            private var videoThumbnailUrl: URL
            
            init(videoID: String, title: String, uploadUrl: String) {
                self.videoTitle = title
                self.videoURI = uploadUrl
                
                self.videoThumbnailUrl = URL(
                    string: YouTubeUploadView.THUMBNAIL_URI_TEMPLATE.replacingOccurrences(of: "%@", with: videoID))!
            }
            
            private static let UPLOAD_IMG_WIDTH: CGFloat = 175
            private static let UPLOAD_IMG_HEIGHT: CGFloat = YouTubeUploadView.UPLOAD_IMG_WIDTH * 0.6
            private static let THUMBNAIL_URI_TEMPLATE = "https://img.youtube.com/vi/%@/mqdefault.jpg"
            
            var body: some View {
                VStack {
                    HStack(spacing: 15)  {
                        RoundedRectImage(width: YouTubeUploadView.UPLOAD_IMG_WIDTH, height: YouTubeUploadView.UPLOAD_IMG_HEIGHT, imageUrl: videoThumbnailUrl, cornerRadius: 8)
                            .equatable()
                        Text(videoTitle)
                            .font(.subheadline)
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
    }
}

#Preview("Default") {
    YouTubeUploadsView(ytUplaods: [],
                       dataTaskStatus: .done,
                       networkError: nil,
                       retryCB: {})
    .padding(.horizontal)
}

#Preview("Loading") {
    YouTubeUploadsView(ytUplaods: [],
                       dataTaskStatus: .pending,
                       networkError: nil,
                       retryCB: {})
    .padding(.horizontal)
}

#Preview("Network Error") {
    YouTubeUploadsView(ytUplaods: [],
                       dataTaskStatus: .error,
                       networkError: .timeout,
                       retryCB: {})
    .padding(.horizontal)
}

