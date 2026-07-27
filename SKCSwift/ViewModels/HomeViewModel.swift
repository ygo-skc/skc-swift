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
    @ObservationIgnored
    private(set) var todaysDate = Date()
    
    private(set) var dbStatsDTS: DataTaskStatus = .pending
    private(set) var cotdDTS: DataTaskStatus = .pending
    private(set) var upcomingTCGProductsDTS: DataTaskStatus = .pending
    private(set) var ytUploadsDTS: DataTaskStatus = .pending
    private(set) var productsReleasedTodayDTS: DataTaskStatus = .pending
    
    @ObservationIgnored
    private(set) var dbStatsNE: NetworkError? = nil
    @ObservationIgnored
    private(set) var cotdNE: NetworkError? = nil
    @ObservationIgnored
    private(set) var upcomingTCGProductsNE: NetworkError? = nil
    @ObservationIgnored
    private(set) var ytUploadsNE: NetworkError? = nil
    @ObservationIgnored
    private(set) var productsReleasedTodayNE: NetworkError? = nil
    
    @ObservationIgnored
    private(set) var dbStats = SKCDatabaseStats(productTotal: 0, cardTotal: 0, banListTotal: 0)
    @ObservationIgnored
    private(set) var cardOfTheDay = CardOfTheDay(date: "1993-07-27", card: .placeholder, version: 1)
    @ObservationIgnored
    private(set) var upcomingTCGProducts = [Event]()
    @ObservationIgnored
    private(set) var ytUploads = [YouTubeVideos]()
    @ObservationIgnored
    private(set) var productsReleasedToday = [Product]()
    
    var path = NavigationPath()
    
    @ObservationIgnored
    private var lastRefreshTimestamp: Date?
    
    func fetchData(forceRefresh: Bool) async {
        todaysDate = Date()
        if lastRefreshTimestamp == nil || (forceRefresh && (lastRefreshTimestamp?.isDateInvalidated(5) == true)) {
            await withTaskGroup(of: Void.self) { taskGroup in
                taskGroup.addTask { @Sendable in await self.fetchDBStatsData() }
                taskGroup.addTask { @Sendable in await self.fetchCardOfTheDayData() }
                taskGroup.addTask { @Sendable in await self.fetchUpcomingTCGProducts() }
                taskGroup.addTask { @Sendable in await self.fetchProductsReleasedToday() }
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
    
    func fetchProductsReleasedToday() async {
        (productsReleasedTodayNE, productsReleasedTodayDTS) = (nil, .pending)
        let res = await getProductsReleasedSameDay(date: Date.yyyyMMddLocal.formatter.string(from: todaysDate))
        if case .success(let p) = res {
            self.productsReleasedToday = p
        }
        (productsReleasedTodayNE, productsReleasedTodayDTS) = res.validate(method: "Products Released Today")
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
        guard let destination = determineTypeOfURLClick(path: url.relativePath) else {
            return .systemAction
        }
        switch destination {
        case .card(let id):
            path.append(CardLinkDestinationValue(cardID: id, cardName: ""))
        case .product(let id):
            path.append(ProductLinkDestinationValue(productID: id, productName: ""))
        }
        return .handled
    }
    
    nonisolated private func determineTypeOfURLClick(path: String) -> URLDestination? {
        if path.contains("/card/") {
            return .card(path.replacingOccurrences(of: "/card/", with: ""))
        } else if path.contains("/product/") {
            return .product(path.replacingOccurrences(of: "/product/", with: ""))
        }
        return nil
    }
}

private enum URLDestination {
    case card(String)
    case product(String)
}
