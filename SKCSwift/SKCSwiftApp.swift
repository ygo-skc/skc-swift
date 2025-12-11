//
//  SKCSwiftApp.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/1/23.
//

import SwiftUI
import SwiftData
import Kingfisher

@main
struct SKCSwiftApp: App {
    init() {
        URLCache.shared = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024)
        
        ImageCache.default.memoryStorage.config.totalCostLimit = 30 * 1024 * 1024
        ImageCache.default.memoryStorage.config.expiration = .seconds(600)
        
        ImageCache.default.diskStorage.config.sizeLimit = 50 * 1024 * 1024
        ImageCache.default.diskStorage.config.expiration = .days(1)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(ArchiveContainer.archiveModelContainer)
    }
}
