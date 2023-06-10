//
//  BanList.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/3/23.
//

struct BanList: Codable {
    var banListDate: String
    var cardID: String
    var banStatus: String
    var format: String
}

struct BanListsForCard: Codable {
    var TCG: [BanList]?
    var MD: [BanList]?
    var DL: [BanList]?
}

struct BanListDates: Codable {
    var banListDates: [BanListDate]
    var _links: HLink
}

struct BanListDate: Codable {
    var format: String
    var effectiveDate: String
}
