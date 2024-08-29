//
//  EnumsFile.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/18/23.
//

import Foundation

enum Attribute: String {
    case dark = "Dark", light = "Light", earth = "Earth", wind = "Wind", water = "Water", fire = "Fire", divine = "Divine", spell = "Spell", trap = "Trap", unknown
}

enum BanListFormat: String {
    case tcg = "TCG", md = "Master Duel", dl = "Duel Links"
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

enum CardColorIndicatorVariant {
    case small
    case regular
    case large
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
    case pending, done, error
}

enum DataFetchError: Error {
    case client
    case server
    case notFound
    case badRequest
    case bodyParse
    case cancelled
    case unknown
}

extension DataFetchError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .client:
            return "Client error"
        case .server:
            return "Server error"
        case .notFound:
            return "404 not found"
        case .badRequest:
            return "400 bad request"
        case .bodyParse:
            return "Cannot parse body"
        case .cancelled:
            return "Request cancelled by client"
        case .unknown:
            return "Unknown"
        }
    }
}

extension DataFetchError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .client:
            return self.description
        case .server:
            return self.description
        case .notFound:
            return self.description
        case .badRequest:
            return self.description
        case .bodyParse:
            return self.description
        case .cancelled:
            return self.description
        case .unknown:
            return self.description
        }
    }
}
