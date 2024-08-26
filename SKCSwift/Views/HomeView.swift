//
//  HomeViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct HomeView: View {
    @State private var homeViewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack(path: $homeViewModel.navigationPath) {
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
            .environment(\.openURL, OpenURLAction(handler: homeViewModel.handleURLClick))
            .navigationBarTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                // below code is needed else refreshable task will be cancelled https://stackoverflow.com/questions/74977787/why-is-async-task-cancelled-in-a-refreshable-modifier-on-a-scrollview-ios-16
                await Task(priority: .userInitiated) {
                    await homeViewModel.fetchData(refresh: true)
                }.value
            }
            .task(priority: .userInitiated) {
                await homeViewModel.fetchData(refresh: false)
            }
        }
    }
}

#Preview("Home") {
    HomeView()
}
