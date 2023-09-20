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
    private let UPLOAD_IMG_WIDTH: CGFloat
    private let UPLOAD_IMG_HEIGHT: CGFloat
    
    init(isDataInvalidated: Binding<Bool> = .constant(false))  {
        self._isDataInvalidated = isDataInvalidated
        
        UPLOAD_IMG_WIDTH = 175
        UPLOAD_IMG_HEIGHT = UPLOAD_IMG_WIDTH * 0.6
    }
    
    private func fetchData() {
        if !isDataLoaded || isDataInvalidated {
            request(url: ytUploadsURL(ytChannelId: YouTubeUploadsView.SKC_CHANNEL_ID)) { (result: Result<YouTubeUploads, Error>) -> Void in
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
                    disableDestination: true,
                    variant: .plain,
                    destination: {EmptyView()},
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
                        YouTubeUploadView(title: video.title, uploadUrl: video.url, thumbnailUrl: "https://img.youtube.com/vi/\(video.id)/maxresdefault.jpg", thumbnailWidth: UPLOAD_IMG_WIDTH, thumbnailHeight: UPLOAD_IMG_HEIGHT)
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

struct YouTubeUploadView: View {
    var title: String
    var uploadUrl: String
    var thumbnailUrl: String
    var thumbnailWidth: CGFloat
    var thumbnailHeight: CGFloat
    
    var body: some View {
        VStack {
            HStack(spacing: 15)  {
                RoundedRectImage(width: thumbnailWidth, height: thumbnailHeight, imageUrl: URL(string: thumbnailUrl)!, cornerRadius: 8)
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
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
            if let url = URL(string: uploadUrl) {
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
        
        YouTubeUploadView(
            title: "Maze of Memories!", uploadUrl: "https://www.youtube.com/watch?v=gonORZrOd68",
            thumbnailUrl: "https://img.youtube.com/vi/NI4awGRwIDs/maxresdefault.jpg", thumbnailWidth: 150, thumbnailHeight: 150 * 0.75
        )
        .padding(.horizontal)
        .previewDisplayName("YouTube Upload")
    }
}
