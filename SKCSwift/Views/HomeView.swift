//
//  HomeViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct HomeView: View {
    @State private var navigationPath = NavigationPath()
    private let homeViewModel = HomeViewModel()
    
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
                    UpcomingTCGProductsView(events: homeViewModel.upcomingTCGProducts)
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
                // below code is needed else refreshable task will be cancelled https://stackoverflow.com/questions/74977787/why-is-async-task-cancelled-in-a-refreshable-modifier-on-a-scrollview-ios-16
                await Task(priority: .userInitiated) {
                    await homeViewModel.fetchData()
                }.value
            }
            .task(priority: .userInitiated) {
                await homeViewModel.fetchData()
            }
        }
    }
}

#Preview("Home") {
    HomeView()
}
