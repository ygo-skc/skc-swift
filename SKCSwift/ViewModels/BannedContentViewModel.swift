//
//  BannedContentViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 11/11/24.
//

import Foundation

@MainActor
@Observable
final class BannedContentViewModel {
    var chosenFormat = BanListFormat.tcg
    var chosenDateRange = 0
    var showDateSelectorSheet = false
    
    private(set) var banListDates: [BanListDate]?
    private(set) var requestErrors: [BannedContentModelDataType: NetworkError?] = [:]
    
    func fetchBanListDates() async {
        switch await data(banListDatesURL(format: "\(chosenFormat)"), resType: BanListDates.self) {
        case .success(let dates):
            banListDates = dates.banListDates
            chosenDateRange = 0
        case .failure(_): break
        }
    }
    
    enum BannedContentModelDataType {
        case dates
    }
}
