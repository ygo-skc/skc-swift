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

struct HSelf: Codable {
    var href: String
}
