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
    
    private(set) var timelineDTS: DataTaskStatus = .pending
    private(set) var contentDTS: DataTaskStatus = .pending
    
    @ObservationIgnored
    private(set) var timelineNE: NetworkError? = nil
    @ObservationIgnored
    private(set) var contentNE: NetworkError? = nil
    
    @ObservationIgnored
    private(set) var restrictionDates: [BanListDate] = []
    
    @ObservationIgnored
    private var bannedContent: BannedContent?
    @ObservationIgnored
    var restrictedCards: [YGOCard] {
        return switch chosenBannedContentCategory {
        case .forbidden:
            bannedContent?.forbidden ?? []
        case .limited:
            bannedContent?.limited ?? []
        case .semiLimited:
            bannedContent?.semiLimited ?? []
        }
    }
    
    @ObservationIgnored
    private var cardScores: CardScores?
    @ObservationIgnored
    var scoreEntries: [CardScoreEntry] {
        return cardScores?.entries ?? []
    }
    
    func fetchTimelineData() async {
        (timelineNE, timelineDTS) = (nil, .pending)
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
        if timelineNE != nil { return }
        
        (contentNE, contentDTS) = (nil, .pending)
        switch format {
        case .tcg, .md:
            await fetchBannedContent()
        case .genesys:
            await fetchScoresByFormatAndDate()
        }
    }
    
    private func fetchBannedContentTimeline() async {
        let res = await data(banListDatesURL(format: format), resType: BanListDates.self)
        if case .success(let data) = res {
            restrictionDates = data.banListDates
        }
        (timelineNE, timelineDTS) = res.validate()
    }
    
    private func fetchCardScoreTimeline() async {
        let res = await YGOService.getRestrictionDates(format: format.rawValue)
        if case .success(let data) = res {
            restrictionDates = data.map({BanListDate(effectiveDate: $0)})
        }
        (timelineNE, timelineDTS) = res.validate(method: "Card Score Timeline")
    }
    
    private func fetchBannedContent() async {
        let res = await data(bannedContentURL(format: format,
                                              listStartDate: restrictionDates[dateRangeIndex].effectiveDate,
                                              saveBandwidth: false,
                                              allInfo: false),
                             resType: BannedContent.self)
        if case .success(let bannedContent) = res {
            self.bannedContent = bannedContent
        }
        (contentNE, contentDTS) = res.validate()
    }
    
    private func fetchScoresByFormatAndDate() async {
        let res = await YGOService.getScoresByFormatAndDate(format: format.rawValue,
                                                            date: restrictionDates[dateRangeIndex].effectiveDate,
                                                            mapper: CardScoreEntry.fromRPC)
        if case .success(let cardScores) = res {
            self.cardScores = CardScores(entries: cardScores)
        }
        (contentNE, contentDTS) = res.validate(method: "Card Scores By Format and Date")
    }
}
