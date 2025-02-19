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
    @Environment(\.modelContext) private var modelContext
    
    // in MB
    @State var networkCacheSize: Double = 0
    @State var fileCacheSize: Double = 0
    @State var isDeleting = false
    
    private let fileManager = FileManager.default
    
    private func calculateFileCacheSize() -> Double {
        var fileCacheSizeInBytes: UInt64 = 0
        if let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            do {
                fileCacheSizeInBytes = try cacheDirectory.calculateDirectorySize(manager: fileManager)
            } catch {
                print("Error calculating cache size: \(error.localizedDescription)")
            }
        }
        
        return Double(fileCacheSizeInBytes) / (1024 * 1024)
    }
    
    @MainActor
    private func reCalculateCacheSizes() {
        isDeleting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            Task {
                networkCacheSize = Double(URLCache.shared.currentDiskUsage) / (1024 * 1024)
                fileCacheSize = calculateFileCacheSize()
                isDeleting = false
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Settings")
                    .font(.title)
                SectionView(header: "Data",
                            content: {
                    SettingsModule(
                        moduleHeader: "Network Cache (~\(String(format: "%.2f", networkCacheSize)) MB)",
                        moduleFootnote: "Cache data is used to speed up loading times and improve performance.") {
                            URLCache.shared.removeAllCachedResponses()
                            reCalculateCacheSizes()
                        } label: {
                            Label("Delete Network Cache", systemImage: "trash.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.bottom)
                    
                    SettingsModule(
                        moduleHeader: "Cache Files (~\(String(format: "%.2f", fileCacheSize)) MB)",
                        moduleFootnote: "This will also delete network cache.") {
                            if let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
                                do {
                                    try cacheDirectory.deleteContents(manager: fileManager)
                                    reCalculateCacheSizes()
                                } catch {
                                    print("Error calculating cache size: \(error.localizedDescription)")
                                }
                            }
                        } label: {
                            Label("Delete File Cache", systemImage: "trash.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.bottom)
                    
                    SettingsModule(
                        moduleHeader: "Recently Viewed History",
                        moduleFootnote: "Recently viewed data facilitates going back to previously viewed items. Deleting this means you will lose access to this data accross all devices.") {
                            try? modelContext.delete(model: History.self)
                            reCalculateCacheSizes()
                            try? modelContext.save()
                        } label: {
                            Label("Delete History", systemImage: "trash.fill")
                                .frame(maxWidth: .infinity)
                        }
                })
            }
            .allowsHitTesting(!isDeleting)
            .modifier(ParentViewModifier())
        }
        .task {
            networkCacheSize = Double(URLCache.shared.currentDiskUsage) / (1024 * 1024)
            fileCacheSize = calculateFileCacheSize()
        }
        .overlay {
            if isDeleting {
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
