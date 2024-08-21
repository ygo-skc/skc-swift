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
    private var dbStatsRefreshTimestamp = Date()
    @ObservationIgnored
    private var cardOfTheDayRefreshTimeStamp = Date()
    @ObservationIgnored
    private var upcomingTCGProductsRefreshTimeStamp = Date()
    @ObservationIgnored
    private var ytUploadsRefreshTimeStamp = Date()
    
    func refresh() async {
        await withTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask { await self.fetchDBStatsData() }
            taskGroup.addTask { await self.fetchCardOfTheDayData() }
            taskGroup.addTask { await self.fetchUpcomingTCGProducts() }
        }
    }
    
    private func isDataInvalidated(date: Date) -> Bool {
        return date.timeIntervalSinceNow(millisConversion: .minutes) >= 5
    }
    
    func fetchDBStatsData() async {
        if dbStats == nil || self.isDataInvalidated(date: self.dbStatsRefreshTimestamp),
            let dbStats = try? await data(SKCDatabaseStats.self, url: dbStatsURL()) {
            DispatchQueue.main.async {
                self.dbStats = dbStats
            }
        }
        self.dbStatsRefreshTimestamp = Date()
    }
    
    func fetchCardOfTheDayData() async {
        if cardOfTheDay == nil || self.isDataInvalidated(date: self.cardOfTheDayRefreshTimeStamp),
           let cardOfTheDay = try? await data(CardOfTheDay.self, url: cardOfTheDayURL()) {
            DispatchQueue.main.async {
                self.cardOfTheDay = cardOfTheDay
            }
        }
        self.cardOfTheDayRefreshTimeStamp = Date()
    }
    
    func fetchUpcomingTCGProducts() async {
        if upcomingTCGProducts == nil || self.isDataInvalidated(date: self.upcomingTCGProductsRefreshTimeStamp),
           let upcomingTCGProducts = try? await data(Events.self, url: upcomingEventsURL()) {
            DispatchQueue.main.async {
                self.upcomingTCGProducts = upcomingTCGProducts.events
            }
        }
        self.upcomingTCGProductsRefreshTimeStamp = Date()
        await fetchYouTubeUploadsData()
    }
    
    private func fetchYouTubeUploadsData() async {
        if ytUploads == nil || self.isDataInvalidated(date: self.ytUploadsRefreshTimeStamp),
            let uploadData = try? await data(YouTubeUploads.self, url: ytUploadsURL(ytChannelId: "UCBZ_1wWyLQI3SV9IgLbyiNQ")) {
            DispatchQueue.main.async {
                self.ytUploads = uploadData.videos
            }
        }
        self.ytUploadsRefreshTimeStamp = Date()
    }
}
