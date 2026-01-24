//
//  HomeViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/28/24.
//

import Foundation
import SwiftUI

@Observable
final class HomeViewModel {
    private(set) var dbStatsDTS: DataTaskStatus = .pending
    private(set) var cotdDTS: DataTaskStatus = .pending
    private(set) var upcomingTCGProductsDTS: DataTaskStatus = .pending
    private(set) var ytUploadsDTS: DataTaskStatus = .pending
    
    @ObservationIgnored
    private(set) var dbStatsNE: NetworkError? = nil
    @ObservationIgnored
    private(set) var cotdNE: NetworkError? = nil
    @ObservationIgnored
    private(set) var upcomingTCGProductsNE: NetworkError? = nil
    @ObservationIgnored
    private(set) var ytUploadsNE: NetworkError? = nil
    
    @ObservationIgnored
    private(set) var dbStats = SKCDatabaseStats(productTotal: 0, cardTotal: 0, banListTotal: 0)
    @ObservationIgnored
    private(set) var cardOfTheDay = CardOfTheDay(date: "", version: 1, card: .placeholder)
    @ObservationIgnored
    private(set) var upcomingTCGProducts = [Event]()
    @ObservationIgnored
    private(set) var ytUploads = [YouTubeVideos]()
    
    var path = NavigationPath()
    
    @ObservationIgnored
    private var lastRefreshTimestamp: Date?
    
    func fetchData(forceRefresh: Bool) async {
        if lastRefreshTimestamp == nil || (forceRefresh && lastRefreshTimestamp!.isDateInvalidated(5)) {
            await withTaskGroup(of: Void.self) { taskGroup in
                taskGroup.addTask { @Sendable in await self.fetchDBStatsData() }
                taskGroup.addTask { @Sendable in await self.fetchCardOfTheDayData() }
                taskGroup.addTask { @Sendable in await self.fetchUpcomingTCGProducts() }
                taskGroup.addTask(priority: .medium) { @Sendable in await self.fetchYouTubeUploadsData() }
            }
            lastRefreshTimestamp = Date()
        }
    }
    
    func fetchDBStatsData() async {
        (dbStatsNE, dbStatsDTS) = (nil, .pending)
        let res = await data(dbStatsURL(), resType: SKCDatabaseStats.self)
        if case .success(let dbStats) = res {
            self.dbStats = dbStats
        }
        (dbStatsNE, dbStatsDTS) = res.validate()
    }
    
    func fetchCardOfTheDayData() async {
        (cotdNE, cotdDTS) = (nil, .pending)
        let res = await data(cardOfTheDayURL(), resType: CardOfTheDay.self)
        if case .success(let cardOfTheDay) = res {
            self.cardOfTheDay = cardOfTheDay
        }
        (cotdNE, cotdDTS) = res.validate()
    }
    
    func fetchUpcomingTCGProducts() async {
        (upcomingTCGProductsNE, upcomingTCGProductsDTS) = (nil, .pending)
        let res = await data(upcomingEventsURL(), resType: Events.self)
        if case .success(let data) = res {
            self.upcomingTCGProducts = data.events
        }
        (upcomingTCGProductsNE, upcomingTCGProductsDTS) = res.validate()
    }
    
    func fetchYouTubeUploadsData() async {
        (ytUploadsNE, ytUploadsDTS) = (nil, .pending)
        let res = await data(ytUploadsURL(ytChannelId: "UCBZ_1wWyLQI3SV9IgLbyiNQ"), resType: YouTubeUploads.self)
        if case .success(let data) = res {
            self.ytUploads = data.videos
        }
        (ytUploadsNE, ytUploadsDTS) = res.validate()
    }
    
    func handleURLClick(_ url: URL) -> OpenURLAction.Result {
        let (destination, type) = determineTypeOfURLClick(path: url.relativePath)
        if let destination {
            type == "product" ?  path.append(ProductLinkDestinationValue(productID: destination, productName: "")) : path.append(CardLinkDestinationValue(cardID: destination, cardName: ""))
            return .handled
        }
        return .systemAction
    }
    
    nonisolated private func determineTypeOfURLClick(path: String) -> (String?, String) {
        if path.contains("/card/") {
            return (path.replacingOccurrences(of: "/card/", with: ""), "card")
        } else if path.contains("/product/") {
            return (path.replacingOccurrences(of: "/product/", with: ""), "product")
        }
        return( nil, "")
    }
}
