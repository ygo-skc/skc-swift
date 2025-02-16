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
    case tcg = "TCG", md = "Master Duel"
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
    case pending, done, uninitiated
}

enum NetworkError: Error {
    case client
    case server
    case badRequest
    case notFound
    case unprocessableEntity
    case reqEncode
    case resDecode
    case cancelled
    case timeout
    case unknown
}

extension NetworkError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .client, .reqEncode:
            return "Client error"
        case .server:
            return "Server error"
        case .badRequest:
            return "400 bad request"
        case .notFound:
            return "404 not found"
        case .unprocessableEntity:
            return "422 unproccessable entity"
        case .resDecode:
            return "Cannot parse body"
        case .cancelled:
            return "Request cancelled by client"
        case .timeout:
            return "Request time out"
        case .unknown:
            return "Unknown"
        }
    }
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .client, .server, .badRequest, .notFound, .unprocessableEntity, .reqEncode, .resDecode, .cancelled, .timeout, .unknown:
            return self.description
        }
    }
}
