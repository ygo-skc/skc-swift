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
                                dataTaskStatus: model.dbStatsDTS,
                                networkError: model.dbStatsNE,
                                retryCB: model.fetchDBStatsData)
                    .equatable()
                    
                    CardOfTheDayView(path: $model.path, cotd: model.cardOfTheDay,
                                     dataTaskStatus:  model.cotdDTS,
                                     networkError: model.cotdNE,
                                     retryCB: model.fetchCardOfTheDayData)
                    .equatable()
                    
                    UpcomingTCGProductsView(events: model.upcomingTCGProducts,
                                            dataTaskStatus: model.upcomingTCGProductsDTS,
                                            networkError: model.upcomingTCGProductsNE,
                                            retryCB: model.fetchUpcomingTCGProducts)
                    .equatable()
                    
                    if model.upcomingTCGProductsDTS == .done {
                        YouTubeUploadsView(ytUplaods: model.ytUploads,
                                           dataTaskStatus: model.ytUploadsDTS,
                                           networkError: model.ytUploadsNE,
                                           retryCB: model.fetchYouTubeUploadsData)
                        .equatable()
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
                        .modify {
                            if #available(iOS 26.0, *) {
                                $0.navigationTransition(.zoom(sourceID: "settings", in: animation))
                            } else {
                                $0
                            }
                        }
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
}

private struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var model = SettingsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Settings")
                    .font(.title)
                SectionView(header: "Data",
                            content: {
                    SettingsModule(
                        moduleHeader: "Network Cache (~\(model.networkCacheSize.formatted(.number.precision(.fractionLength(2)))) MB)",
                        moduleFootnote: "Cache data is used to speed up loading times and improve performance.",
                        action: model.deleteNetworkCache) {
                            Label("Delete Network Cache", systemImage: "trash.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.bottom)
                    
                    SettingsModule(
                        moduleHeader: "Cache Files (~\(model.fileCacheSize.formatted(.number.precision(.fractionLength(2)))) MB)",
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
            .modifier(.sheetParentView)
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
    
    private struct SettingsModule<Label: View>: View {
        let moduleHeader: String
        let moduleFootnote: String?
        let action: () async -> Void
        let label: Label
        
        @State private var isAlertOpen = false
        
        init(moduleHeader: String,
             moduleFootnote: String?,
             action: @escaping () async -> Void,
             label: () -> Label,
             isAlertOpen: Bool = false) {
            self.moduleHeader = moduleHeader
            self.moduleFootnote = moduleFootnote
            self.action = action
            self.label = label()
            self.isAlertOpen = isAlertOpen
        }
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(moduleHeader)
                    .font(.headline)
                if let moduleFootnote = moduleFootnote {
                    Text(moduleFootnote)
                        .font(.footnote)
                }
                
                Button { isAlertOpen.toggle() } label: { label }
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
}

#Preview("Home") {
    HomeView()
}
