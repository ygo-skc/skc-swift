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
    
    private var fetchTask: Task<(), Never>?
    
    private func fetchBanListDates() async {
        switch await data(banListDatesURL(format: format), resType: BanListDates.self) {
        case .success(let dates):
            banListDates = dates.banListDates
            dateRangeIndex = 0
        case .failure(_): break
        }
    }
    
    private func fetchBannedContent() async {
        switch await data(bannedContentURL(format: format, listStartDate: banListDates[dateRangeIndex].effectiveDate, saveBandwidth: false , allInfo: false), resType: BannedContent.self) {
        case .success(let bannedContent):
            self.bannedContent = bannedContent
        case .failure(_): break
        }
    }
    
    func fetchData(formatChanged: Bool = false) async {
        if let fetchTask {
            await fetchTask.value
            return
        }
        
        fetchTask = Task {
            if banListDates.isEmpty || formatChanged {
                await fetchBanListDates()
            }
            await fetchBannedContent()
        }
        
        await fetchTask?.value
        fetchTask = nil
    }
    
    enum BannedContentModelDataType {
        case dates
    }
}
