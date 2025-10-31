//
//  SettingsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 2/26/25.
//

import Foundation
import SwiftData

@Observable
final class SettingsViewModel {
    private(set) var networkCacheSize: Double = 0
    private(set) var fileCacheSize: Double = 0
    private(set) var isDeleting = false
    
    func calculateDataUsage() async {
        (networkCacheSize, fileCacheSize) = await calculateFileCacheSize()
        isDeleting = false
    }
    
    func deleteNetworkCache() async {
        await deleteData(deleteTaskType: .networkCache)
    }
    
    func deleteFileCache() async {
        await deleteData(deleteTaskType: .fileCache)
    }
    
    func deleteHistoryData(modelContext: ModelContext) async {
        await deleteData(deleteTaskType: .historyModelData, modelContext: modelContext)
    }
    
    private func deleteData(deleteTaskType: DeleteTaskType, modelContext: ModelContext? = nil) async {
        isDeleting = true
        switch deleteTaskType {
        case .networkCache:
            URLCache.shared.removeAllCachedResponses()
        case .fileCache:
            await executeDeleteFileCache()
        case .historyModelData:
            try? modelContext!.delete(model: History.self)
            try? modelContext!.save()
        }
        await reCalculateCacheSizes()
    }
    
    @concurrent
    private func calculateFileCacheSize() async -> (Double, Double) {
        let fileManager = FileManager.default
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
    
    @concurrent
    private func executeDeleteFileCache() async {
        let fileManager = FileManager.default
        if let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            do {
                try cacheDirectory.deleteContents(manager: fileManager)
            } catch {
                print("Error calculating cache size: \(error.localizedDescription)")
            }
        }
    }
    
    @concurrent
    private func reCalculateCacheSizes() async {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            Task {
                await self.calculateDataUsage()
            }
        }
    }
    
    private enum DeleteTaskType {
        case networkCache, fileCache, historyModelData
    }
}
