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
    private(set) var requestErrors: [HomeModelDataType: NetworkError?] = [:]
    
    private(set) var dbStats: SKCDatabaseStats?
    private(set) var cardOfTheDay: CardOfTheDay?
    private(set) var upcomingTCGProducts: [Event]?
    private(set) var ytUploads: [YouTubeVideos]?
    
    var navigationPath = NavigationPath()
    
    @ObservationIgnored
    private var lastRefreshTimestamp: Date?
    
    @MainActor
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
    
    @MainActor
    func fetchDBStatsData() async {
        switch await data(SKCDatabaseStats.self, url: dbStatsURL()) {
        case .success(let dbStats):
            self.dbStats = dbStats
            requestErrors[.dbStats] = nil
        case .failure(let error):
            requestErrors[.dbStats] = error
        }
    }
    
    @MainActor
    func fetchCardOfTheDayData() async {
        switch await data(CardOfTheDay.self, url: cardOfTheDayURL()) {
        case .success(let cardOfTheDay):
            self.cardOfTheDay = cardOfTheDay
            requestErrors[.cardOfTheDay] = nil
        case .failure(let error):
            requestErrors[.cardOfTheDay] = error
        }
    }
    
    @MainActor
    func fetchUpcomingTCGProducts() async {
        switch await data(Events.self, url: upcomingEventsURL()) {
        case .success(let upcomingTCGProducts):
            self.upcomingTCGProducts = upcomingTCGProducts.events
            requestErrors[.upcomingTCGProducts] = nil
        case .failure(let error):
            requestErrors[.upcomingTCGProducts] = error
        }
    }
    
    @MainActor
    func fetchYouTubeUploadsData() async {
        switch await data(YouTubeUploads.self, url: ytUploadsURL(ytChannelId: "UCBZ_1wWyLQI3SV9IgLbyiNQ")) {
        case .success(let uploadData):
            self.ytUploads = uploadData.videos
            requestErrors[.youtubeUploads] = nil
        case .failure(let error):
            requestErrors[.youtubeUploads] = error
        }
    }
    
    @MainActor
    func handleURLClick(_ url: URL) -> OpenURLAction.Result {
        let path = url.relativePath
        if path.contains("/card/") {
            navigationPath.append(CardLinkDestinationValue(cardID: path.replacingOccurrences(of: "/card/", with: ""), cardName: ""))
            return .handled
        }
        return .systemAction
    }
    
    enum HomeModelDataType {
        case dbStats, cardOfTheDay, upcomingTCGProducts, youtubeUploads
    }
}
