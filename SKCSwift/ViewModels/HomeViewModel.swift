//
//  HomeViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/28/24.
//

import Foundation

@Observable
class HomeViewModel {
    private(set) var dbStats: SKCDatabaseStats?
    private(set) var cardOfTheDay: CardOfTheDay?
    private(set) var upcomingTCGProducts: [Event]?
    private(set) var ytUploads: [YouTubeVideos]?
    
    @ObservationIgnored
    private var lastRefreshTimestamp: Date?
    
    func fetchData(refresh: Bool) async {
        if lastRefreshTimestamp == nil || (refresh && lastRefreshTimestamp!.isDateInvalidated(5)) {
            await withTaskGroup(of: Void.self) { taskGroup in
                taskGroup.addTask { await self.fetchDBStatsData() }
                taskGroup.addTask { await self.fetchCardOfTheDayData() }
                taskGroup.addTask { await self.fetchUpcomingTCGProducts() }
                taskGroup.addTask(priority: .medium) { await self.fetchYouTubeUploadsData() }
            }
            lastRefreshTimestamp = Date()
        }
    }
    
    func fetchDBStatsData() async {
        if let dbStats = try? await data(SKCDatabaseStats.self, url: dbStatsURL()) {
            DispatchQueue.main.async {
                self.dbStats = dbStats
            }
        }
    }
    
    func fetchCardOfTheDayData() async {
        if let cardOfTheDay = try? await data(CardOfTheDay.self, url: cardOfTheDayURL()) {
            DispatchQueue.main.async {
                self.cardOfTheDay = cardOfTheDay
            }
        }
    }
    
    func fetchUpcomingTCGProducts() async {
        if let upcomingTCGProducts = try? await data(Events.self, url: upcomingEventsURL()) {
            DispatchQueue.main.async {
                self.upcomingTCGProducts = upcomingTCGProducts.events
            }
        }
    }
    
    func fetchYouTubeUploadsData() async {
        if let uploadData = try? await data(YouTubeUploads.self, url: ytUploadsURL(ytChannelId: "UCBZ_1wWyLQI3SV9IgLbyiNQ")) {
            DispatchQueue.main.async {
                self.ytUploads = uploadData.videos
            }
        }
    }
}
