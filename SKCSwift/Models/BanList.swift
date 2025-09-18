//
//  BanList.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/3/23.
//

nonisolated struct BanList: Codable, Equatable {
    let banListDate, cardID, banStatus, format: String
}

nonisolated struct BanListsForCard: Codable, Equatable {
    let TCG, MD: [BanList]?
}

nonisolated struct BanListDates: Codable, Hashable {
    let banListDates: [BanListDate]
}

nonisolated struct BanListDate: Codable, Hashable {
    let effectiveDate: String
}

nonisolated struct BannedContent: Codable, Equatable {
    let numForbidden, numLimited, numSemiLimited, numLimitedOne, numLimitedTwo, numLimitedThree: UInt8
    let forbidden, limited, semiLimited: [Card]
}
