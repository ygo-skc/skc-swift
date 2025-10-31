//
//  xxx.swift
//  SKCSwift
//
//  Created by Javi Gomez on 10/31/25.
//

import SwiftData

let archiveContainer: ModelContainer = {
    let config = ModelConfiguration(cloudKitDatabase: .private("iCloud.com.skc.app.Archive"))
    return try! ModelContainer(for: Schema([Favorite.self, History.self]), configurations: config)
}()
