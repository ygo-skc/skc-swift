//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct YouTubeUploadsView: View {
    @State private var videos = [YouTubeVideos]()
    @State private var isDataLoaded = false
    
    private let SKC_CHANNEL_ID = "UCBZ_1wWyLQI3SV9IgLbyiNQ"
    private let UPLOAD_IMG_WIDTH = UIScreen.main.bounds.width * 0.35
    private let UPLOAD_IMG_HEIGHT = UIScreen.main.bounds.width * 0.28
    
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
            LazyVStack(alignment: .leading, spacing: 5) {
                Text("Did you know I make YouTube videos? Keep tabs of TCG news, watch the best unboxings on YouTube and watch me play Master Duel. Don't forget to sub.")
                    .font(.body)
                    .padding(.bottom)
                
                if !isDataLoaded {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
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
            }
            .frame(maxWidth: .infinity)
            .onAppear {
                fetchData()
            }
        })
    }
}

struct YouTubeUploadsView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            YouTubeUploadsView()
                .padding(.horizontal)
        }
    }
}
