//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct YouTubeUploadsView: View {
    var parentWidth = UIScreen.main.bounds.width
    
    @State private var videos = [YouTubeVideos]()
    @State private var isDataLoaded = false
    
    private let SKC_CHANNEL_ID = "UCBZ_1wWyLQI3SV9IgLbyiNQ"
    let UPLOAD_IMG_WIDTH: CGFloat
    let UPLOAD_IMG_HEIGHT: CGFloat
    
    init()  {
        UPLOAD_IMG_WIDTH = parentWidth * 0.35
        UPLOAD_IMG_HEIGHT = parentWidth * 0.28
    }
    
    func fetchData() {
        if isDataLoaded {
            return
        }
        
        request(url: ytUploadsURL(ytChannelId: SKC_CHANNEL_ID)) { (result: Result<YouTubeUploads, Error>) -> Void in
            DispatchQueue.main.async {
                switch result {
                case .success(let uploadData):
                    self.videos = uploadData.videos
                    self.isDataLoaded = true
                case .failure(let error):
                    print(error)
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
                        HStack(spacing: 20)  {
                            RoundedRectImage(width: UPLOAD_IMG_WIDTH, height: UPLOAD_IMG_HEIGHT, imageUrl: URL(string: video.thumbnailUrl)!, cornerRadius: 10)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(video.title)
                                    .font(.callout)
                                    .fontWeight(.regular)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                        Divider()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        })
        .onAppear {
            fetchData()
        }
    }
}

struct YouTubeUploadsView_Previews: PreviewProvider {
    static var previews: some View {
        YouTubeUploadsView()
            .padding(.horizontal)
    }
}
