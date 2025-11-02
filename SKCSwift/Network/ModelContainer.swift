//
//  ModelContainer.swift
//  SKCSwift
//
//  Created by Javi Gomez on 10/31/25.
//

import SwiftUI
import SwiftData

struct ArchiveContainer {
    static let archiveModelContainer: ModelContainer = {
        let config = ModelConfiguration(cloudKitDatabase: .private("iCloud.com.skc.app.Archive"))
        return try! ModelContainer(for: Schema([Favorite.self, History.self]), configurations: config)
    }()
    
    static func fetchHistoryByAccessDate(sortOrder: SortOrder, limit: Int? = 20) -> FetchDescriptor<History> {
        let cardResource = ArchiveResource.card.rawValue
        var descriptor = FetchDescriptor<History>(
            predicate: #Predicate { $0.resource == cardResource },
            sortBy: [SortDescriptor(\.lastAccessDate, order: sortOrder)]
        )
        
        descriptor.fetchLimit = limit
        return descriptor
    }
    
    static func fetchHistoryResourceByID(id: String) -> FetchDescriptor<History> {
        return FetchDescriptor<History>(
            predicate: #Predicate { $0.id == id }
        )
    }
}
