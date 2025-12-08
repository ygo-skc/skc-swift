//
//  EnumsFile.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/18/23.
//

enum Attribute: String {
    case dark = "Dark",
         light = "Light",
         earth = "Earth",
         wind = "Wind",
         water = "Water",
         fire = "Fire",
         divine = "Divine",
         spell = "Spell",
         trap = "Trap",
         unknown
}

enum MonsterType: String {
    case aqua = "Aqua",
         beastWarrior = "Beast-Warrior",
         beast = "Beast",
         cyberse = "Cyberse",
         dinosaur = "Dinosaur",
         divineBeast = "Divine-Beast",
         dragon = "Dragon",
         fairy = "Fairy",
         fiend = "Fiend",
         fish = "Fish",
         illusion = "Illusion",
         insect = "Insect",
         machine = "Machine",
         plant = "Plant",
         psychic = "Psychic",
         pyro = "Pyro",
         reptile = "Reptile",
         rock = "Rock",
         seaSerpent = "Sea Serpent",
         spellcaster = "Spellcaster",
         thunder = "Thunder",
         warrior = "Warrior",
         wingedBeast = "Winged Beast",
         wyrm = "Wyrm",
         zombie = "Zombie",
         unknown
}

enum CardRestrictionFormat: String {
    case tcg = "TCG", md = "Master Duel", genesys = "Genesys"
}

enum BannedContentCategory: String {
    case forbidden = "Forbidden", limited = "Limited", semiLimited = "Semi-Limited"
}

enum RelatedContentType: String {
    case products = "Products", banLists = "Ban Lists"
}

enum CardType {
    case monster
    case nonMonster
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

enum YGOCardImageVariant {
    case round
    case roundedCorner
}

enum ImageSize: String {
    case tiny = "tn", extraSmall = "x-sm", small = "sm", medium = "md", large = "lg", original = "original"
}

enum TrendingResourceType: String, Codable, CaseIterable {
    case card = "CARD", product = "PRODUCT"
}

enum DataTaskStatus: String, Codable, CaseIterable {
    case pending, done, uninitiated, error
}
