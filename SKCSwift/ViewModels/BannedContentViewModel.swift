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
    var format = BanListFormat.tcg
    var dateRangeIndex: Int = 0
    
    private(set) var banListDates: [BanListDate] = []
    private(set) var bannedContent: BannedContent?
    private(set) var requestErrors: [BannedContentModelDataType: NetworkError?] = [:]
    
    func fetchBanListDates() async {
        switch await data(banListDatesURL(format: format), resType: BanListDates.self) {
        case .success(let dates):
            banListDates = dates.banListDates
            dateRangeIndex = 0
        case .failure(_): break
        }
    }
    
    func fetchBannedContent() async {
        if !banListDates.isEmpty {
            switch await data(bannedContentURL(format: format, listStartDate: banListDates[dateRangeIndex].effectiveDate, saveBandwidth: false , allInfo: false), resType: BannedContent.self) {
            case .success(let bannedContent):
                self.bannedContent = bannedContent
            case .failure(_): break
            }
        }
    }
    
    enum BannedContentModelDataType {
        case dates
    }
}
