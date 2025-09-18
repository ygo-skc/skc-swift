//
//  SettingsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 2/26/25.
//

import Foundation
import SwiftData

fileprivate actor DataManagementActor {
    private let fileManager = FileManager.default
    
    func calculateFileCacheSize() -> (Double, Double) {
        var fileCacheSizeInBytes: UInt64 = 0
        if let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            do {
                fileCacheSizeInBytes = try cacheDirectory.calculateDirectorySize(manager: fileManager)
            } catch {
                print("Error calculating cache size: \(error.localizedDescription)")
            }
        }
        
        return (Double(URLCache.shared.currentDiskUsage) / (1024 * 1024), Double(fileCacheSizeInBytes) / (1024 * 1024))
    }
    
    func deleteFileCache() {
        if let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            do {
                try cacheDirectory.deleteContents(manager: fileManager)
            } catch {
                print("Error calculating cache size: \(error.localizedDescription)")
            }
        }
    }
}

@Observable
final class SettingsViewModel {
    private(set) var networkCacheSize: Double = 0
    private(set) var fileCacheSize: Double = 0
    private(set) var isDeleting = false
    
    @ObservationIgnored
    private let dataManagementActor = DataManagementActor()
    
    func calculateDataUsage() async {
        (networkCacheSize, fileCacheSize) = await dataManagementActor.calculateFileCacheSize()
        isDeleting = false
    }
    
    func deleteNetworkCache() {
        isDeleting = true
        Task {
            URLCache.shared.removeAllCachedResponses()
            await reCalculateCacheSizes()
        }
    }
    
    func deleteFileCache() {
        isDeleting = true
        Task {
            await dataManagementActor.deleteFileCache()
            await reCalculateCacheSizes()
        }
    }
    
    func deleteHistoryData(modelContext: ModelContext) {
        isDeleting = true
        Task {
            try? modelContext.delete(model: History.self)
            try? modelContext.save()
            await reCalculateCacheSizes()
        }
    }
    
    private func reCalculateCacheSizes() async {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            Task {
                await self.calculateDataUsage()
            }
        }
    }
}
