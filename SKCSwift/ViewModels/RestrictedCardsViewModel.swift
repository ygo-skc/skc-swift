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
    private(set) var timelineDTS: DataTaskStatus = .uninitiated
    private(set) var contentDTS: DataTaskStatus = .uninitiated
    
    @ObservationIgnored
    private(set) var timelineNE: NetworkError? = nil
    @ObservationIgnored
    private(set) var contentNE: NetworkError? = nil
    
    var format = CardRestrictionFormat.tcg
    var dateRangeIndex: Int = 0
    var chosenBannedContentCategory = BannedContentCategory.forbidden
    
    @ObservationIgnored
    private(set) var restrictionDates: [BanListDate] = []
    @ObservationIgnored
    private var bannedContent: BannedContent?
    
    @ObservationIgnored
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
    
    private var cardScores: CardScores?
    var scoreEntries: [CardScoreEntry]? {
        return cardScores?.entries
    }
    
    func fetchTimelineData() async {
        timelineDTS = .pending
        switch format {
        case .tcg, .md:
            await fetchBannedContentTimeline()
            chosenBannedContentCategory = .forbidden
        case .genesys:
            await fetchCardScoreTimeline()
        }
        dateRangeIndex = 0
        await fetchRestrictedCards()
    }
    
    func fetchRestrictedCards() async {
        contentDTS = .pending
        switch format {
        case .tcg, .md:
            await fetchBannedContent()
        case .genesys:
            await fetchScoresByFormatAndDate()
        }
    }
    
    private func fetchBannedContentTimeline() async {
        let res = await data(banListDatesURL(format: format), resType: BanListDates.self)
        restrictionDates = (try? res.get().banListDates) ?? [BanListDate]()
        (timelineNE, timelineDTS) = res.validate()
    }
    
    private func fetchCardScoreTimeline() async {
        let res = await YGOService.getRestrictionDates(format: format.rawValue)
        restrictionDates = (try? res.get().map( {BanListDate(effectiveDate: $0) } )) ?? []
//        (timelineNE, timelineDTS) = res.validate()
    }
    
    private func fetchBannedContent() async {
//        switch await data(bannedContentURL(format: format,
//                                           listStartDate: restrictionDates[dateRangeIndex].effectiveDate,
//                                           saveBandwidth: false,
//                                           allInfo: false),
//                          resType: BannedContent.self) {
//        case .success(let bannedContent):
//            dataTaskStatuses[.content] = .done
//            self.bannedContent = bannedContent
//        case .failure(_): break
//        }
    }
    
    private func fetchScoresByFormatAndDate() async {
//        switch await YGOService.getScoresByFormatAndDate(format: format.rawValue,
//                                                         date: restrictionDates[dateRangeIndex].effectiveDate,
//                                                         mapper: CardScoreEntry.fromRPC) {
//        case .success(let entries):
//            dataTaskStatuses[.content] = .done
//            self.cardScores = CardScores(entries: entries)
//        case .failure(_): break
//        }
    }
}
