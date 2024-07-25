//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct YouTubeUploadsView: View {
    @Binding private var isDataInvalidated: Bool
    
    @State private var videos = [YouTubeVideos]()
    @State private var isDataLoaded = false
    
    private static let SKC_CHANNEL_ID = "UCBZ_1wWyLQI3SV9IgLbyiNQ"
    
    init(isDataInvalidated: Binding<Bool> = .constant(false))  {
        self._isDataInvalidated = isDataInvalidated
    }
    
    private func fetchData() {
        if !isDataLoaded || isDataInvalidated {
            request(url: ytUploadsURL(ytChannelId: YouTubeUploadsView.SKC_CHANNEL_ID), priority: 0.0) { (result: Result<YouTubeUploads, Error>) -> Void in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let uploadData):
                        if self.videos != uploadData.videos {
                            self.videos = uploadData.videos
                        }
                        
                        self.isDataLoaded = true
                        self.isDataInvalidated = false
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    var body: some View {
        SectionView(header: "YouTube videos",
                    variant: .plain,
                    content: {
            if !isDataLoaded {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                LazyVStack(alignment: .leading, spacing: 5) {
                    Text("Did you know I make YouTube videos? Keep tabs of TCG news, watch the best unboxings on YouTube and also watch some dope Master Duel replays. Don't forget to sub.")
                        .font(.body)
                        .padding(.bottom)
                    
                    ForEach(videos, id: \.id) { video in
                        YouTubeUploadView(videoID: video.id, title: video.title, uploadUrl: video.url)
                            .equatable()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        })
        .onChange(of: $isDataInvalidated.wrappedValue, initial: true) {
            fetchData()
        }
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
                .frame(alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = URL(string: videoURI) {
                UIApplication.shared.open(url)
            }
        }
    }
}

struct YouTubeUploadsView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            YouTubeUploadsView()
                .padding(.horizontal)
        }
        .frame(maxHeight: .infinity)
        .previewDisplayName("YouTube Uploads Feed")
        
        YouTubeUploadView(videoID: "NI4awGRwIDs", title: "Maze of Memories!", uploadUrl: "https://www.youtube.com/watch?v=gonORZrOd68")
        .padding(.horizontal)
        .previewDisplayName("YouTube Upload")
    }
}
