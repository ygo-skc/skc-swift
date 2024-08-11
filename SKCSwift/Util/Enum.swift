//
//  EnumsFile.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/18/23.
//

enum Attribute: String {
    case dark = "Dark", light = "Light", earth = "Earth", wind = "Wind", water = "Water", fire = "Fire", divine = "Divine", spell = "Spell", trap = "Trap", unknown
}

enum BanListFormat: String {
    case tcg = "TCG", md = "Master Duel", dl = "Duel Links"
}

enum RelatedContentType: String {
    case products = "Products", ban_lists = "Ban Lists"
}

enum CardType {
    case monster
    case non_monster
}

enum SectionViewVariant {
    case plain
    case styled
}

enum DateBadgeViewVariant {
    case normal
    case condensed
}

enum YGOCardViewVariant {
    case normal
    case condensed
    case listView
}

enum CardColorIndicatorVariant {
    case small
    case regular
}

enum YGOCardImageVariant {
    case round
    case roundedCorner
}

enum ImageSize: String {
    case tiny = "tn", extra_small = "x-sm", small = "sm", medium = "md", large = "lg", original = "original"
}

enum TrendingResourceType: String, Codable, CaseIterable {
    case card = "CARD", product = "PRODUCT"
}

enum DataTaskStatus: String, Codable, CaseIterable {
    case pending, done, error
}
