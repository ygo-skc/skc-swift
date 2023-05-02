//
//  EnumsFile.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/18/23.
//

import Foundation

enum Attribute: String {
    case dark = "Dark", light = "Light", earth = "Earth", wind = "Wind", water = "Water", fire = "Fire"
}

enum BanListFormat: String {
    case tcg = "TCG", md = "Master Duel", dl = "Duel Links"
}

enum RelatedContentType: String {
    case products = "Products", ban_lists = "Ban Lists"
}

enum CardStatsViewVariant {
    case normal
    case condensed
}

enum CardType {
    case monster
    case non_monster
}

enum SectionViewVariant {
    case plain
    case styled
}

enum DateViewVariant {
    case normal
    case condensed
}
