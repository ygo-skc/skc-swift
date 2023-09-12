//
//  HATEOAS.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/10/23.
//

import Foundation

struct HLink: Codable, Hashable {
    var `self`: HSelf
}

struct BanListDateHLink: Codable, Hashable {
    var banListContent: HSelf
    var banListNewContent: HSelf
    var banListRemovedContent: HSelf
    
    // allows decoding and encoding custom key names
    private enum CodingKeys : String, CodingKey {
        case banListContent = "Ban List Content", banListNewContent = "Ban List New Content", banListRemovedContent = "Ban List Removed Content"
    }
}

struct HSelf: Codable, Hashable {
    var href: String
}
