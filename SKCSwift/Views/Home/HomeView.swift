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
        NavigationStack(path: $model.path) {
            ScrollView {
                VStack(spacing: 30) {
                    DBStatsView(dbStats: model.dbStats,
                                isDataLoaded: model.dataTaskStatus[.dbStats, default: .uninitiated] == .done,
                                networkError: model.requestErrors[.dbStats, default: nil],
                                retryCB: model.fetchDBStatsData)
                    .equatable()
                    
                    CardOfTheDayView(path: $model.path, cotd: model.cardOfTheDay,
                                     isDataLoaded:  model.dataTaskStatus[.cardOfTheDay, default: .uninitiated] == .done,
                                     networkError: model.requestErrors[.cardOfTheDay, default: nil],
                                     retryCB: model.fetchCardOfTheDayData)
                    .equatable()
                    
                    UpcomingTCGProductsView(events: model.upcomingTCGProducts,
                                            isDataLoaded: model.dataTaskStatus[.upcomingTCGProducts, default: .uninitiated] == .done,
                                            networkError: model.requestErrors[.upcomingTCGProducts, default: nil],
                                            retryCB: model.fetchUpcomingTCGProducts)
                    .equatable()
                    
                    YouTubeUploadsView(ytUplaods: model.ytUploads,
                                       isDataLoaded: model.dataTaskStatus[.youtubeUploads, default: .uninitiated] == .done,
                                       networkError: model.requestErrors[.youtubeUploads, default: nil],
                                       retryCB: model.fetchYouTubeUploadsData)
                    .equatable()
                    .if(model.dataTaskStatus[.cardOfTheDay, default: .uninitiated] != .done) { view in
                        view.hidden()
                    }
                }
                .toolbar {
                    HomeViewToolbar()
                }
                .ygoNavigationDestination()
                .modifier(.parentView)
            }
            .environment(\.openURL, OpenURLAction(handler: model.handleURLClick))
            .navigationBarTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                // below code is needed else refreshable task will be cancelled https://stackoverflow.com/questions/74977787/why-is-async-task-cancelled-in-a-refreshable-modifier-on-a-scrollview-ios-16
                await Task(priority: .userInitiated) {
                    await model.fetchData(forceRefresh: true)
                }.value
            }
            .task(priority: .userInitiated) {
                await model.fetchData(forceRefresh: false)
            }
        }
    }
}

private struct HomeViewToolbar: ToolbarContent {
    @State private var isSettingsSheetPresented = false
    @Namespace private var animation
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isSettingsSheetPresented = true
            } label: {
                Image(systemName: "gear")
            }
            .sheet(isPresented: $isSettingsSheetPresented) {
                SettingsView()
                    .presentationDetents([.medium, .large])
                    .navigationTransition(.zoom(sourceID: "settings", in: animation))
            }
        }
        .modify {
            if #available(iOS 26.0, *) {
                $0.matchedTransitionSource(id: "settings", in: animation)
            } else {
                $0
            }
        }
    }
}

private struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var model = SettingsViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Settings")
                    .font(.title)
                SectionView(header: "Data",
                            content: {
                    SettingsModule(
                        moduleHeader: "Network Cache (~\(String(format: "%.2f", model.networkCacheSize)) MB)",
                        moduleFootnote: "Cache data is used to speed up loading times and improve performance.",
                        action: model.deleteNetworkCache) {
                            Label("Delete Network Cache", systemImage: "trash.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.bottom)
                    
                    SettingsModule(
                        moduleHeader: "Cache Files (~\(String(format: "%.2f", model.fileCacheSize)) MB)",
                        moduleFootnote: "This will also delete network cache.",
                        action: model.deleteFileCache) {
                            Label("Delete File Cache", systemImage: "trash.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.bottom)
                    
                    SettingsModule(
                        moduleHeader: "Recently Viewed History",
                        moduleFootnote: "Recently viewed data facilitates going back to previously viewed items. Deleting this means you will lose access to this data accross all devices.") {
                            await model.deleteHistoryData(modelContext: modelContext)
                        } label: {
                            Label("Delete History", systemImage: "trash.fill")
                                .frame(maxWidth: .infinity)
                        }
                })
            }
            .allowsHitTesting(!model.isDeleting)
            .modifier(.parentView)
        }
        .task {
            await model.calculateDataUsage()
        }
        .overlay {
            if model.isDeleting {
                ProgressView("Deleting...")
                    .controlSize(.large)
            }
        }
    }
}

private struct SettingsModule<Label: View>: View {
    let moduleHeader: String
    let moduleFootnote: String?
    let action: () async -> Void
    @ViewBuilder let label: () -> Label
    
    @State private var isAlertOpen = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(moduleHeader)
                .font(.headline)
            if let moduleFootnote = moduleFootnote {
                Text(moduleFootnote)
                    .font(.footnote)
            }
            
            Button { isAlertOpen.toggle() } label: { label() }
                .alert("Proceed with deletion?", isPresented: $isAlertOpen) {
                    Button("Cancel", role: .cancel) {}
                    Button("🫡", role: .destructive) {
                        Task {
                            await action()
                        }
                    }
                } message: {
                    Text("Action is irreversible.")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Home") {
    HomeView()
}
