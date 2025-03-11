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
                    DBStatsView(dbStats: model.dbStats,
                                isDataLoaded: model.dataTaskStatus[.dbStats, default: .uninitiated] == .done,
                                networkError: model.requestErrors[.dbStats, default: nil],
                                retryCB: model.fetchDBStatsData)
                    .equatable()
                    
                    CardOfTheDayView(cotd: model.cardOfTheDay,
                                     isDataLoaded:  model.dataTaskStatus[.cardOfTheDay, default: .uninitiated] == .done,
                                     networkError: model.requestErrors[.cardOfTheDay, default: nil],
                                     retryCB: model.fetchCardOfTheDayData)
                    .equatable()
                    .onTapGesture{
                        if model.dataTaskStatus[.cardOfTheDay, default: .uninitiated] == .done && model.requestErrors[.cardOfTheDay, default: nil] == nil {
                            model.navigationPath.append(CardLinkDestinationValue(cardID: model.cardOfTheDay.card.cardID,
                                                                                 cardName: model.cardOfTheDay.card.cardName))
                        }
                    }
                    
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
                    Button {
                        model.isSettingsSheetPresented = true
                    } label: {
                        Image(systemName: "gear")
                    }
                    .sheet(isPresented: $model.isSettingsSheetPresented) {
                        SettingsView()
                    }
                }
                .ygoNavigationDestination()
                .modifier(ParentViewModifier())
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
                            model.deleteHistoryData(modelContext: modelContext)
                        } label: {
                            Label("Delete History", systemImage: "trash.fill")
                                .frame(maxWidth: .infinity)
                        }
                })
            }
            .allowsHitTesting(!model.isDeleting)
            .modifier(ParentViewModifier())
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
    let action: () -> Void
    @ViewBuilder let label: () -> Label
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(moduleHeader)
                .font(.headline)
            if let moduleFootnote = moduleFootnote {
                Text(moduleFootnote)
                    .font(.footnote)
            }
            
            Button(action: action, label: label)
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Home") {
    HomeView()
}
