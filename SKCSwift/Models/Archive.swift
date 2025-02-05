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
}

@Model
class Favorite {
//    #Unique<Favorite>([\.type, \.id])
    
    var type: String = "favorites"
    var resource: ArchiveResource = ArchiveResource.card
    var id: String = ""
    
    init(type: String = "favorites", resource: ArchiveResource, id: String) {
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
    
    init(resource: ArchiveResource, id: String, lastAccessDate: Date = Date(), timesAccessed: Int = 0) {
        self.resource = resource.rawValue
        self.id = id
        self.lastAccessDate = lastAccessDate
        self.timesAccessed = timesAccessed
    }
    
    func updateAccess(timesAccessed: Int = 1) {
        lastAccessDate = Date()
        self.timesAccessed += timesAccessed
    }
}
