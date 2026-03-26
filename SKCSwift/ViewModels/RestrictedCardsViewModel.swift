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
    
    var sort = RestrictedContentSortOrder.cardNameAsc
    
    private(set) var timelineDTS: DataTaskStatus = .pending
    private(set) var contentDTS: DataTaskStatus = .pending
    
    @ObservationIgnored
    private(set) var timelineNE: NetworkError? = nil
    @ObservationIgnored
    private(set) var contentNE: NetworkError? = nil
    
    @ObservationIgnored
    private(set) var restrictionDates: [BanListDate] = []
    
    @ObservationIgnored
    var restrictedContentEffectiveDateStr: String? {
        if timelineDTS != .done || timelineNE != nil {
            return nil
        } else {
            return restrictionDates[dateRangeIndex].effectiveDate
        }
    }
    
    @ObservationIgnored
    var restrictedContentEffectiveDate: Date? {
        if let restrictedContentEffectiveDateStr {
            return Date.yyyyMMddLocalFormatter.date(from: restrictedContentEffectiveDateStr) ?? nil
        }
        return nil
    }
    
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
    
    @ObservationIgnored
    var totalEntries: UInt16 {
        if format == .genesys {
            return UInt16(cardScores?.totalEntries ?? 0)
        }
        return (bannedContent?.numForbidden ?? 0 ) + (bannedContent?.numLimited ?? 0) + (bannedContent?.numSemiLimited ?? 0)
    }
    
    @ObservationIgnored
    var totalForbidden: UInt16 {
        return bannedContent?.numForbidden ?? 0
    }
    
    @ObservationIgnored
    var totalLimited: UInt16 {
        return bannedContent?.numLimited ?? 0
    }
    
    @ObservationIgnored
    var totalSemiLimited: UInt16 {
        return bannedContent?.numSemiLimited ?? 0
    }
    
    @ObservationIgnored
    var genesysTotalRange1: UInt16 {
        let entries = (cardScores?.entries ?? []).filter({$0.score <= 30})
        return UInt16(entries.count)
    }
    
    @ObservationIgnored
    var genesysTotalRange2: UInt16 {
        let entries = (cardScores?.entries ?? []).filter({$0.score > 30 && $0.score <= 70})
        return UInt16(entries.count)
    }
    
    @ObservationIgnored
    var genesysTotalRange3: UInt16 {
        let entries = (cardScores?.entries ?? []).filter({$0.score > 70})
        return UInt16(entries.count)
    }
    
    func fetchTimelineData() async {
        (timelineNE, timelineDTS) = (nil, .pending)
        switch format {
        case .tcg, .md:
            let res = await data(banListDatesURL(format: format), resType: BanListDates.self)
            if case .success(let data) = res {
                restrictionDates = data.banListDates
            }
            (timelineNE, timelineDTS) = res.validate()
            
            chosenBannedContentCategory = .forbidden
        case .genesys:
            let res = await YGOService.getRestrictionDates(format: format.rawValue)
            if case .success(let data) = res {
                restrictionDates = data.map({BanListDate(effectiveDate: $0)})
            }
            (timelineNE, timelineDTS) = res.validate(method: "Card Score Timeline")
        }
        dateRangeIndex = 0
        await fetchRestrictedCards()
    }
    
    func fetchRestrictedCards() async {
        if timelineNE != nil { return }
        
        (contentNE, contentDTS) = (nil, .pending)
        switch format {
        case .tcg, .md:
            let res = await data(
                bannedContentURL(
                    format: format,
                    listStartDate: restrictionDates[dateRangeIndex].effectiveDate,
                    saveBandwidth: false,
                    allInfo: false),
                resType: BannedContent.self)
            if case .success(let bannedContent) = res {
                self.bannedContent = bannedContent
            }
            (contentNE, contentDTS) = res.validate()
        case .genesys:
            let res = await YGOService.getScoresByFormatAndDate(
                format: format.rawValue,
                date: restrictionDates[dateRangeIndex].effectiveDate,
                sort: sort.rawValue,
                scoreMapper: CardScores.fromRPC,
                entryMapper: CardScoreEntry.fromRPC)
            if case .success(let c) = res {
                self.cardScores = c
            }
            (contentNE, contentDTS) = res.validate(method: "Card Scores By Format and Date")
        }
    }
}

enum RestrictedContentSortOrder: Int, CaseIterable {
    case cardNameAsc = 0, cardScoreDesc = 1
    
    var title: String {
        switch self {
        case .cardNameAsc:
            return "Card Name"
        case .cardScoreDesc:
            return "Card Score"
        }
    }
    
    var subtitle: String {
        switch self {
        case .cardNameAsc:
            return "A-Z"
        case .cardScoreDesc:
            return "9-0"
        }
    }
}
