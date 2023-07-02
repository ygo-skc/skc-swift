//
//  HATEOAS.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/10/23.
//

import Foundation

struct HLink: Codable {
    var `self`: HSelf
}

struct BanListDateHLink: Codable {
    var banListContent: HSelf
    var banListNewContent: HSelf
    var banListRemovedContent: HSelf
    
    // allows decoding and encoding custom key names
    private enum CodingKeys : String, CodingKey {
        case banListContent = "Ban List Content", banListNewContent = "Ban List New Content", banListRemovedContent = "Ban List Removed Content"
    }
}

struct HSelf: Codable {
    var href: String
}
