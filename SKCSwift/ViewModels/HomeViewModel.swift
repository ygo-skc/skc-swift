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
    
    func fetchDBStatsData() {
        if dbStats == nil || self.isDataInvalidated(date: self.dbStatsRefreshTimestamp) {
            request(url: dbStatsURL(), priority: 0.3) { (result: Result<SKCDatabaseStats, Error>) -> Void in
                switch result {
                case .success(let dbStats):
                    self.dbStatsRefreshTimestamp = Date()
                    DispatchQueue.main.async {
                        self.dbStats = dbStats
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func fetchCardOfTheDayData() {
        if cardOfTheDay == nil || self.isDataInvalidated(date: self.cardOfTheDayRefreshTimeStamp)  {
            request(url: cardOfTheDayURL(), priority: 0.25) { (result: Result<CardOfTheDay, Error>) -> Void in
                self.fetchUpcomingTCGProducts()
                switch result {
                case .success(let cardOfTheyDay):
                    self.cardOfTheDayRefreshTimeStamp = Date()
                    if self.cardOfTheDay?.date != cardOfTheyDay.date {
                        DispatchQueue.main.async {
                            self.cardOfTheDay = cardOfTheyDay
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func fetchUpcomingTCGProducts() {
        if upcomingTCGProducts == nil || self.isDataInvalidated(date: self.upcomingTCGProductsRefreshTimeStamp) {
            request(url: upcomingEventsURL(), priority: 0.2) { (result: Result<Events, Error>) -> Void in
                self.fetchYouTubeUploadsData()
                switch result {
                case .success(let upcomingProducts):
                    self.upcomingTCGProductsRefreshTimeStamp = Date()
                    if self.upcomingTCGProducts != upcomingProducts.events {
                        DispatchQueue.main.async {
                            self.upcomingTCGProducts = upcomingProducts.events
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func fetchYouTubeUploadsData() {
        if ytUploads == nil || self.isDataInvalidated(date: self.ytUploadsRefreshTimeStamp) {
            request(url: ytUploadsURL(ytChannelId: "UCBZ_1wWyLQI3SV9IgLbyiNQ"), priority: 0.0) { (result: Result<YouTubeUploads, Error>) -> Void in
                switch result {
                case .success(let uploadData):
                    self.ytUploadsRefreshTimeStamp = Date()
                    if self.ytUploads != uploadData.videos {
                        DispatchQueue.main.async {
                            self.ytUploads = uploadData.videos
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func load() async {
        if dbStats == nil || cardOfTheDay == nil {
            self.fetchDBStatsData()
            self.fetchCardOfTheDayData()
        }
    }
    
    func refresh() async {
        self.fetchDBStatsData()
        self.fetchCardOfTheDayData()
        
        repeat {
            try? await Task.sleep(for: .milliseconds(250))
        } while self.isDataInvalidated(date: self.dbStatsRefreshTimestamp) || self.isDataInvalidated(date: self.cardOfTheDayRefreshTimeStamp)
        || self.isDataInvalidated(date: self.upcomingTCGProductsRefreshTimeStamp) || self.isDataInvalidated(date: self.ytUploadsRefreshTimeStamp)
    }
    
    private func isDataInvalidated(date: Date) -> Bool {
        return date.timeIntervalSinceNow(millisConversion: .minutes) >= 5
    }
}
