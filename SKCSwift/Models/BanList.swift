//
//  BanList.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/3/23.
//

struct BanList: Codable, Equatable {
    let banListDate, cardID, banStatus, format: String
}

struct BanListsForCard: Codable, Equatable {
    let TCG, MD: [BanList]?
}

struct BanListDates: Codable, Hashable {
    let banListDates: [BanListDate]
}

struct BanListDate: Codable, Hashable {
    let effectiveDate: String
}

struct BannedContent: Codable, Equatable {
    let numForbidden, numLimited, numSemiLimited, numLimitedOne, numLimitedTwo, numLimitedThree: UInt8
    let forbidden, limited, semiLimited: [Card]
}
