//
//  HomeViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var homeViewModel: HomeViewModel
    @State private var navigationPath = NavigationPath()
    
    init() {
        _homeViewModel = StateObject(wrappedValue: HomeViewModel())
    }
    
    private func handleURL(_ url: URL) -> OpenURLAction.Result {
        let path = url.relativePath
        if path.contains("/card/") {
            navigationPath.append(CardLinkDestinationValue(cardID: path.replacingOccurrences(of: "/card/", with: ""), cardName: ""))
            return .handled
        }
        return .systemAction
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 30) {
                    DBStatsView(stats: homeViewModel.dbStats)
                        .equatable()
                    CardOfTheDayView(cardOfTheDay: homeViewModel.cardOfTheDay)
                        .equatable()
                    UpcomingTCGProductsView(events: homeViewModel.upcommingTCGProducts)
                        .equatable()
                    YouTubeUploadsView(videos: homeViewModel.ytUploads)
                        .equatable()
                        .if(homeViewModel.ytUploads == nil) { view in
                            view.hidden()
                        }
                }
                .modifier(ParentViewModifier())
            }
            .navigationDestination(for: CardLinkDestinationValue.self) { card in
                CardLinkDestinationView(cardLinkDestinationValue: card)
            }
            .environment(\.openURL, OpenURLAction(handler: handleURL))
            .navigationBarTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await homeViewModel.refresh()
            }
            .task(priority: .low) {
                homeViewModel.load()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
