//
//  HATEOAS.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/10/23.
//

struct HLink: Codable, Hashable {
    let `self`: HSelf
}

struct BanListDateHLink: Codable, Hashable {
    let banListContent: HSelf
    let banListNewContent: HSelf
    let banListRemovedContent: HSelf
    
    // allows decoding and encoding custom key names
    private enum CodingKeys : String, CodingKey {
        case banListContent = "Ban List Content", banListNewContent = "Ban List New Content", banListRemovedContent = "Ban List Removed Content"
    }
}

struct HSelf: Codable, Hashable {
    let href: String
}
