//
//  HomeViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct HomeView: View {
    @State private var isTCGProductsInfoLoaded = false
    
    @State private var isDBStatsDataInvalidated = false
    @State private var isCardOfTheDayDataInvalidated = false
    @State private var isUpcomingTCGProductsInvalidated = false
    @State private var isYouTubeUploadsInvalidated = false
    
    @State private var lastRefresh = Date()
    
    func refresh() async {
        if lastRefresh.timeIntervalSinceNow(millisConversion: .minutes) < 5 {
            isDBStatsDataInvalidated = true
            isCardOfTheDayDataInvalidated = true
            isUpcomingTCGProductsInvalidated = true
            
            if isTCGProductsInfoLoaded {
                isYouTubeUploadsInvalidated = true
            }
            
            
            while(isDBStatsDataInvalidated && isCardOfTheDayDataInvalidated && isUpcomingTCGProductsInvalidated) {
                try? await Task.sleep(for: .milliseconds(500))
            }
            lastRefresh = Date()
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    DBStatsView(isDataInvalidated: $isDBStatsDataInvalidated)
                    CardOfTheDayView(isDataInvalidated: $isCardOfTheDayDataInvalidated)
                    UpcomingTCGProductsView(canLoadNextView: $isTCGProductsInfoLoaded, isDataInvalidated: $isUpcomingTCGProductsInvalidated)
                    
                    if isTCGProductsInfoLoaded {
                        YouTubeUploadsView(isDataInvalidated: $isYouTubeUploadsInvalidated)
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxHeight: .infinity)
            .navigationBarTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await refresh()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
