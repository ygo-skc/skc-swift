//
//  HomeViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/28/24.
//

import Foundation
import SwiftUI

@Observable
class HomeViewModel {
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
            //            await withTaskGroup(of: Void.self) { @MainActor taskGroup in
            //                taskGroup.addTask { await self.fetchDBStatsData() }
            //                taskGroup.addTask { await self.fetchCardOfTheDayData() }
            //                taskGroup.addTask { await self.fetchUpcomingTCGProducts() }
            //                taskGroup.addTask(priority: .medium) { await self.fetchYouTubeUploadsData() }
            //            }
            await self.fetchDBStatsData()
            await self.fetchCardOfTheDayData()
            await self.fetchUpcomingTCGProducts()
            await self.fetchYouTubeUploadsData()
            lastRefreshTimestamp = Date()
        }
    }
    
    @MainActor
    private func fetchDBStatsData() async {
        switch await data(SKCDatabaseStats.self, url: dbStatsURL()) {
        case .success(let dbStats):
            self.dbStats = dbStats
        case .failure(_): break
        }
    }
    
    @MainActor
    private func fetchCardOfTheDayData() async {
        switch await data(CardOfTheDay.self, url: cardOfTheDayURL()) {
        case .success(let cardOfTheDay):
            self.cardOfTheDay = cardOfTheDay
        case .failure(_): break
        }
    }
    
    @MainActor
    private func fetchUpcomingTCGProducts() async {
        switch await data(Events.self, url: upcomingEventsURL()) {
        case .success(let upcomingTCGProducts):
            self.upcomingTCGProducts = upcomingTCGProducts.events
        case .failure(_): break
        }
    }
    
    @MainActor
    private func fetchYouTubeUploadsData() async {
        switch await data(YouTubeUploads.self, url: ytUploadsURL(ytChannelId: "UCBZ_1wWyLQI3SV9IgLbyiNQ")) {
        case .success(let uploadData):
            self.ytUploads = uploadData.videos
        case .failure(_): break
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
}
