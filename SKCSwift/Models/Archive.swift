//
//  Favorites.swift
//  SKCSwift
//
//  Created by Javi Gomez on 2/3/25.
//

import Foundation
import SwiftData

enum ArchiveResource: String, Codable {
    case card = "card"
    case product = "product"
    case none = "none"
}

@Model
class Favorite {
    private(set) var type: String = "favorites"
    private(set) var resource: ArchiveResource = ArchiveResource.card
    private(set) var id: String = ""
    
    init(type: String, resource: ArchiveResource, id: String) {
        self.type = type
        self.resource = resource
        self.id = id
    }
}


@Model
final class History {
    private(set) var resource: String = ArchiveResource.card.rawValue
    private(set) var id: String = ""
    private(set) var lastAccessDate: Date = Date()
    private(set) var timesAccessed: Int = 0
    
    init(resource: ArchiveResource, id: String, lastAccessDate: Date, timesAccessed: Int) {
        self.resource = resource.rawValue
        self.id = id
        self.lastAccessDate = lastAccessDate
        self.timesAccessed = timesAccessed
    }
    
    private func updateAccess(timesAccessed: Int = 1) {
        lastAccessDate = Date()
        self.timesAccessed += timesAccessed
    }
    
    func updateHistoryContext(history: [History], modelContext: ModelContext) {
        /*
         If no history, create new instance in table
         Else if there is at least one history record for card, update the last modified date and access time for the first record
         */
        if history.isEmpty {
            modelContext.insert(self)
        } else if let h1 = history.first, h1.lastAccessDate.timeIntervalSinceNow(millisConversion: .seconds) >= 3 {
            h1.updateAccess()
        }
        
        History.consolidate(history: history, modelContext: modelContext)
        try? modelContext.save()
    }
    
    /// there should only be one history record per ID/resource type, this method will consolidate multiple history records into one - deleting the others
    private static func consolidate(history: [History], modelContext: ModelContext) {
        if history.count > 1 {
            for i in 1..<history.count {
                if history[0].id == history[i].id && history[0].resource == history[i].resource {
                    history[0].updateAccess(timesAccessed: history[i].timesAccessed)
                    modelContext.delete(history[i])
                }
            }
        }
    }
}
