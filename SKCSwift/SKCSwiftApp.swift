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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(ArchiveContainer.archiveModelContainer)
    }
}
