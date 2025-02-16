//
//  HomeViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct HomeView: View {
    @State private var model = HomeViewModel()
    
    var body: some View {
        NavigationStack(path: $model.navigationPath) {
            ScrollView {
                VStack(spacing: 30) {
                    DBStatsView(model: model)
                    CardOfTheDayView(model: model)
                    UpcomingTCGProductsView(model: model)
                    YouTubeUploadsView(model: model)
                        .if(model.upcomingTCGProducts == nil) { view in
                            view.hidden()
                        }
                }
                .modifier(ParentViewModifier())
            }
            .navigationDestination(for: CardLinkDestinationValue.self) { card in
                CardLinkDestinationView(cardLinkDestinationValue: card)
            }
            .environment(\.openURL, OpenURLAction(handler: model.handleURLClick))
            .navigationBarTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                // below code is needed else refreshable task will be cancelled https://stackoverflow.com/questions/74977787/why-is-async-task-cancelled-in-a-refreshable-modifier-on-a-scrollview-ios-16
                await Task(priority: .userInitiated) {
                    await model.fetchData(refresh: true)
                }.value
            }
            .task(priority: .userInitiated) {
                await model.fetchData(refresh: false)
            }
        }
    }
}

#Preview("Home") {
    HomeView()
}
