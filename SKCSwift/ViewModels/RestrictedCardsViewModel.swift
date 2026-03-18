//
//  RestrictedCardsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 11/11/24.
//

import Foundation
import YGOService
import GRPCCore

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
    var chosenRestrictedContentDate: Date? {
        if timelineDTS != .done || timelineNE != nil {
            return nil
        } else {
            return Date.yyyyMMddLocalFormatter.date(from: restrictionDates[dateRangeIndex].effectiveDate) ?? nil
        }
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
    var totalEntries: UInt32 {
        if format == .genesys {
            return cardScores?.totalEntries ?? 0
        }
        return UInt32(bannedContent?.numForbidden ?? 0 ) + UInt32(bannedContent?.numLimited ?? 0) + UInt32(bannedContent?.numSemiLimited ?? 0)
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
