//
//  HomeViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/28/24.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published private(set) var dbStats: SKCDatabaseStats?
    @Published private(set) var cardOfTheDay: CardOfTheDay?
    @Published private(set) var upcommingTCGProducts: [Event]?
    @Published private(set) var ytUploads: [YouTubeVideos]?
    
    private var dbStatsRefresTimetamp = Date(), cardOfTheDayRefreshTimeStamp = Date(), upcommingTCGProductsRefreshTimeStamp = Date(), ytUploadsRefreshTimeStamp = Date()
    
    func fetchDBStatsData() {
        if dbStats == nil || self.isDataInvalidated(date: self.dbStatsRefresTimetamp) {
            request(url: dbStatsURL(), priority: 0.3) { (result: Result<SKCDatabaseStats, Error>) -> Void in
                switch result {
                case .success(let dbStats):
                    self.dbStatsRefresTimetamp = Date()
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
                self.fetchUpcommingTCGProducts()
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
    
    func fetchUpcommingTCGProducts() {
        if upcommingTCGProducts == nil || self.isDataInvalidated(date: self.upcommingTCGProductsRefreshTimeStamp) {
            request(url: upcomingEventsURL(), priority: 0.2) { (result: Result<Events, Error>) -> Void in
                switch result {
                case .success(let upcomingProducts):
                    self.upcommingTCGProductsRefreshTimeStamp = Date()
                    if self.upcommingTCGProducts != upcomingProducts.events {
                        DispatchQueue.main.async {
                            self.upcommingTCGProducts = upcomingProducts.events
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
    
    func refresh() async {
        self.fetchDBStatsData()
        self.fetchCardOfTheDayData()
        
        if self.upcommingTCGProducts != nil {
            self.fetchYouTubeUploadsData()
        }
        
        repeat {
            try? await Task.sleep(for: .milliseconds(250))
        } while self.isDataInvalidated(date: self.dbStatsRefresTimetamp) || self.isDataInvalidated(date: self.cardOfTheDayRefreshTimeStamp)
        || self.isDataInvalidated(date: self.upcommingTCGProductsRefreshTimeStamp) || self.isDataInvalidated(date: self.ytUploadsRefreshTimeStamp)
    }
    
    private func isDataInvalidated(date: Date) -> Bool {
        return date.timeIntervalSinceNow(millisConversion: .minutes) >= 5
    }
}
