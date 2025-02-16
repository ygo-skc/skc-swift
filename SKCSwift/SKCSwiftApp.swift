//
//  SKCSwiftApp.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/1/23.
//

import SwiftUI
import SwiftData

@main
struct SKCSwiftApp: App {
    let archiveContainer: ModelContainer = {
        let config = ModelConfiguration(cloudKitDatabase: .private("iCloud.com.skc.app.Archive"))
        return try! ModelContainer(for: Schema([Favorite.self, History.self]), configurations: config)
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(archiveContainer)
    }
}
