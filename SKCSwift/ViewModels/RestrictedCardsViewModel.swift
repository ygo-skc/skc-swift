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
    
    private(set) var restrictionDates: [BanListDate] = []
    private(set) var requestErrors: [RestrictedCardDataType: NetworkError?] = [:]
    private(set) var isLoadingRestrictedCards = true
    
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
    
    private var cardScores: CardScores?
    var scoreEntries: [CardScoreEntry]? {
        return cardScores?.entries
    }
    
    func fetchTimelineData(formatChanged: Bool = false) async {
        if restrictionDates.isEmpty || formatChanged {
            switch format {
            case .tcg, .md:
                await fetchBannedContentTimeline()
                chosenBannedContentCategory = .forbidden
            case .genesys:
                await fetchCardScoreTimeline()
            }
            dateRangeIndex = 0
        }
    }
    
    func fetchRestrictedCards() async {
        isLoadingRestrictedCards = true
        switch format {
        case .tcg, .md:
            await fetchBannedContent()
        case .genesys:
            await fetchScoresByFormatAndDate()
        }
        isLoadingRestrictedCards = false
    }
    
    private func fetchBannedContentTimeline() async {
        switch await data(banListDatesURL(format: format), resType: BanListDates.self) {
        case .success(let dates):
            restrictionDates = dates.banListDates
        case .failure(_): break
        }
    }
    
    private func fetchCardScoreTimeline() async {
        switch await YGOService.getRestrictionDates(format: format.rawValue) {
        case .success(let scoreEffectiveDates):
            restrictionDates = scoreEffectiveDates.map( {BanListDate(effectiveDate: $0) } )
        case .failure(_): break
        }
    }
    
    private func fetchBannedContent() async {
        switch await data(bannedContentURL(format: format,
                                           listStartDate: restrictionDates[dateRangeIndex].effectiveDate,
                                           saveBandwidth: false,
                                           allInfo: false),
                          resType: BannedContent.self) {
        case .success(let bannedContent):
            self.bannedContent = bannedContent
        case .failure(_): break
        }
    }
    
    private func fetchScoresByFormatAndDate() async {
        switch await YGOService.getScoresByFormatAndDate(format: format.rawValue,
                                                         date: restrictionDates[dateRangeIndex].effectiveDate,
                                                         parser: CardScoreEntry.rpcParser) {
        case .success(let entries):
            self.cardScores = CardScores(entries: entries)
        case .failure(_): break
        }
    }
    
    enum RestrictedCardDataType {
        case bannedContentTimeline, bannedContent, cardScoresTimeline, cardScoresContent
    }
}
