//
//  HomeViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct HomeView: View, Equatable {
    @State private var isTCGProductsInfoLoaded = false
    
    @State private var isDBStatsDataInvalidated = false
    @State private var isCardOfTheDayDataInvalidated = false
    @State private var isUpcomingTCGProductsInvalidated = false
    @State private var isYouTubeUploadsInvalidated = false
    
    @State private var lastRefresh = Date()
    
    @State private var navigationPath = NavigationPath()
    
    static func == (lhs: HomeView, rhs: HomeView) -> Bool {
        lhs.isTCGProductsInfoLoaded == rhs.isTCGProductsInfoLoaded && lhs.isDBStatsDataInvalidated == rhs.isDBStatsDataInvalidated
        && lhs.isCardOfTheDayDataInvalidated == rhs.isCardOfTheDayDataInvalidated && lhs.isUpcomingTCGProductsInvalidated == rhs.isUpcomingTCGProductsInvalidated
        && lhs.isYouTubeUploadsInvalidated == rhs.isYouTubeUploadsInvalidated
    }
    
    private func refresh() async {
        if lastRefresh.timeIntervalSinceNow(millisConversion: .minutes) >= 5 {
            isDBStatsDataInvalidated = true
            isCardOfTheDayDataInvalidated = true
            isUpcomingTCGProductsInvalidated = true
            
            if isTCGProductsInfoLoaded {
                isYouTubeUploadsInvalidated = true
            }
            
            
            while(isDBStatsDataInvalidated && isCardOfTheDayDataInvalidated && isUpcomingTCGProductsInvalidated) {
                try? await Task.sleep(for: .milliseconds(250))
            }
            lastRefresh = Date()
        }
    }
    
    private func handleURL(_ url: URL) -> OpenURLAction.Result {
        let path = url.relativePath
        if path.contains("/card/") {
            navigationPath.append(CardValue(cardID: path.replacingOccurrences(of: "/card/", with: ""), cardName: ""))
            return .handled
        }
        return .systemAction
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 30) {
                    DBStatsView(isDataInvalidated: $isDBStatsDataInvalidated)
                    CardOfTheDayView(isDataInvalidated: $isCardOfTheDayDataInvalidated)
                    UpcomingTCGProductsView(canLoadNextView: $isTCGProductsInfoLoaded, isDataInvalidated: $isUpcomingTCGProductsInvalidated)
                    
                    if isTCGProductsInfoLoaded {
                        YouTubeUploadsView(isDataInvalidated: $isYouTubeUploadsInvalidated)
                    }
                }
                .modifier(ParentViewModifier())
            }
            .navigationDestination(for: CardValue.self) { card in
                CardSearchLinkDestination(cardValue: card)
            }
            .environment(\.openURL, OpenURLAction(handler: handleURL))
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
