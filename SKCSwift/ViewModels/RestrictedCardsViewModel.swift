//
//  RestrictedCardsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 11/11/24.
//

import Foundation
import YGOService
import GRPCCore

@Observable
final class RestrictedCardsViewModel {
    var format = CardRestrictionFormat.tcg
    var dateRangeIndex: Int = 0
    var chosenBannedContentCategory = BannedContentCategory.forbidden
    
    private(set) var banListDates: [BanListDate] = []
    private(set) var requestErrors: [RestrictedCardDataType: NetworkError?] = [:]
    
    private var bannedContent: BannedContent?
    var restrictedCards: [Card]? {
        return switch chosenBannedContentCategory {
        case .forbidden:
            bannedContent?.forbidden
        case .limited:
            bannedContent?.limited
        case .semiLimited:
            bannedContent?.semiLimited
        }
    }
    
    @ObservationIgnored
    private var fetchTask: Task<(), Never>?
    
    private func fetchBannedContentTimeline() async {
        switch await data(banListDatesURL(format: format), resType: BanListDates.self) {
        case .success(let dates):
            banListDates = dates.banListDates
            dateRangeIndex = 0
        case .failure(_): break
        }
    }
    
    private func fetchCardScoreTimeline() async {
        switch await YGOService.getRestrictionDates(format: format.rawValue) {
        case .success(let scoreEffectiveDates):
            banListDates = scoreEffectiveDates.map( {BanListDate(effectiveDate: $0) } )
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
                switch format {
                case .tcg, .md:
                    await fetchBannedContentTimeline()
                    chosenBannedContentCategory = .forbidden
                case .genesys:
                    await fetchCardScoreTimeline()
                }
            }
            switch format {
            case .tcg, .md:
                await fetchBannedContent()
            case .genesys:
                break
            }
        }
        
        await fetchTask?.value
        fetchTask = nil
    }
    
    enum RestrictedCardDataType {
        case bannedContentTimeline, bannedContent, cardScoresTimeline, cardScoresContent
    }
}
