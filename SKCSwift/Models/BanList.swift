//
//  BanList.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/3/23.
//

struct BanList: Codable, Equatable {
    let banListDate: String
    let cardID: String
    let banStatus: String
    let format: String
}

struct BanListsForCard: Codable, Equatable {
    let TCG: [BanList]?
    let MD: [BanList]?
    let DL: [BanList]?
}

struct BanListDates: Codable, Hashable {
    let banListDates: [BanListDate]
}

struct BanListDate: Codable, Hashable {
    let effectiveDate: String
}
