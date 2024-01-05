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
}

enum CardColorIndicatorVariant {
    case small
    case regular
}

enum YGOCardImageVariant {
    case round
    case rounded_corner
}

enum ImageSize: String {
    case tiny = "tn", extra_small = "x-sm", small = "small", medium = "md", large = "lg", original = "original"
}
