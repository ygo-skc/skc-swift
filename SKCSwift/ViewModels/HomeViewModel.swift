//
//  HomeViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/28/24.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class HomeViewModel {
    private(set) var requestErrors: [HomeModelDataType: NetworkError?] = [:]
    
    private(set) var dbStats: SKCDatabaseStats?
    private(set) var cardOfTheDay: CardOfTheDay?
    private(set) var upcomingTCGProducts: [Event]?
    private(set) var ytUploads: [YouTubeVideos]?
    
    var navigationPath = NavigationPath()
    
    var isSettingsSheetPresented = false
    
    @ObservationIgnored
    private var lastRefreshTimestamp: Date?
    
    func fetchData(refresh: Bool) async {
        if lastRefreshTimestamp == nil || (refresh && lastRefreshTimestamp!.isDateInvalidated(5)) {
            await withTaskGroup(of: Void.self) { taskGroup in
                taskGroup.addTask { @Sendable @MainActor in await self.fetchDBStatsData() }
                taskGroup.addTask { @Sendable @MainActor in await self.fetchCardOfTheDayData() }
                taskGroup.addTask { @Sendable @MainActor in await self.fetchUpcomingTCGProducts() }
                taskGroup.addTask(priority: .medium) { @Sendable @MainActor in await self.fetchYouTubeUploadsData() }
            }
            lastRefreshTimestamp = Date()
        }
    }
    
    func fetchDBStatsData() async {
        switch await data(dbStatsURL(), resType: SKCDatabaseStats.self) {
        case .success(let dbStats):
            self.dbStats = dbStats
            requestErrors[.dbStats] = nil
        case .failure(let error):
            requestErrors[.dbStats] = error
        }
    }
    
    func fetchCardOfTheDayData() async {
        switch await data(cardOfTheDayURL(), resType: CardOfTheDay.self) {
        case .success(let cardOfTheDay):
            self.cardOfTheDay = cardOfTheDay
            requestErrors[.cardOfTheDay] = nil
        case .failure(let error):
            requestErrors[.cardOfTheDay] = error
        }
    }
    
    func fetchUpcomingTCGProducts() async {
        switch await data(upcomingEventsURL(), resType: Events.self) {
        case .success(let upcomingTCGProducts):
            self.upcomingTCGProducts = upcomingTCGProducts.events
            requestErrors[.upcomingTCGProducts] = nil
        case .failure(let error):
            requestErrors[.upcomingTCGProducts] = error
        }
    }
    
    func fetchYouTubeUploadsData() async {
        switch await data(ytUploadsURL(ytChannelId: "UCBZ_1wWyLQI3SV9IgLbyiNQ"), resType: YouTubeUploads.self) {
        case .success(let uploadData):
            self.ytUploads = uploadData.videos
            requestErrors[.youtubeUploads] = nil
        case .failure(let error):
            requestErrors[.youtubeUploads] = error
        }
    }
    
    func handleURLClick(_ url: URL) -> OpenURLAction.Result {
        let (destination, type) = determineTypeOfURLClick(path: url.relativePath)
        if let destination {
            type == "product" ?  navigationPath.append(ProductLinkDestinationValue(productID: destination, productName: "")) : navigationPath.append(CardLinkDestinationValue(cardID: destination, cardName: ""))
            return .handled
        }
        return .systemAction
    }
    
    private nonisolated func determineTypeOfURLClick(path: String) -> (String?, String) {
        if path.contains("/card/") {
            return (path.replacingOccurrences(of: "/card/", with: ""), "card")
        } else if path.contains("/product/") {
            return (path.replacingOccurrences(of: "/product/", with: ""), "product")
        }
        return( nil, "")
    }
    
    enum HomeModelDataType {
        case dbStats, cardOfTheDay, upcomingTCGProducts, youtubeUploads
    }
}
