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
                .toolbar {
                    Button {
                        model.isSettingsSheetPresented = true
                    } label: {
                        Image(systemName: "gear")
                    }
                    .sheet(isPresented: $model.isSettingsSheetPresented) {
                        SettingsView()
                    }
                }
                .navigationDestination(for: CardLinkDestinationValue.self) { card in
                    CardLinkDestinationView(cardLinkDestinationValue: card)
                }
                .modifier(ParentViewModifier())
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

private struct SettingsView: View {
    @State var cachedDataSize = URLCache.shared.currentDiskUsage / (1024 * 1024)    // in MB
    @State var isDeleting = false
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Settings")
                    .font(.title)
                
                SectionView(header: "Data",
                            content: {
                    Text("Network Cache (~\(cachedDataSize) MB)")
                        .font(.headline)
                    Text("Note: cache data is used to speed up loading times and improve performance.")
                        .font(.footnote)
                    
                    Button {
                        URLCache.shared.removeAllCachedResponses()
                        isDeleting = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                            Task {
                                cachedDataSize = URLCache.shared.currentDiskUsage / (1024 * 1024)
                                isDeleting = false
                            }
                        }
                    } label: {
                        Label("Delete Cache", systemImage: "trash.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                })
            }
            .allowsHitTesting(!isDeleting)
            .modifier(ParentViewModifier())
        }
        .overlay {
            if isDeleting {
                ProgressView("Deleting...")
                    .controlSize(.large)
            }
        }
    }
}

#Preview("Home") {
    HomeView()
}
