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
    private(set) var dbStatsDTS: DataTaskStatus = .uninitiated
    private(set) var cotdDTS: DataTaskStatus = .uninitiated
    private(set) var upcomingTCGProductsDTS: DataTaskStatus = .uninitiated
    private(set) var ytUploadsDTS: DataTaskStatus = .uninitiated
    
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
        dbStatsDTS = .pending
        switch await data(dbStatsURL(), resType: SKCDatabaseStats.self) {
        case .success(let dbStats):
            self.dbStats = dbStats
            dbStatsNE = nil
            dbStatsDTS = .done
        case .failure(let error):
            dbStatsNE = error
            dbStatsDTS = .error
        }
    }
    
    func fetchCardOfTheDayData() async {
        cotdDTS = .pending
        switch await data(cardOfTheDayURL(), resType: CardOfTheDay.self) {
        case .success(let cardOfTheDay):
            self.cardOfTheDay = cardOfTheDay
            cotdNE = nil
            cotdDTS = .done
        case .failure(let error):
            cotdNE = error
            cotdDTS = .error
        }
    }
    
    func fetchUpcomingTCGProducts() async {
        upcomingTCGProductsDTS = .pending
        switch await data(upcomingEventsURL(), resType: Events.self) {
        case .success(let upcomingTCGProducts):
            self.upcomingTCGProducts = upcomingTCGProducts.events
            upcomingTCGProductsNE = nil
            upcomingTCGProductsDTS = .done
        case .failure(let error):
            upcomingTCGProductsNE = error
            upcomingTCGProductsDTS = .error
        }
    }
    
    func fetchYouTubeUploadsData() async {
        ytUploadsDTS = .pending
        switch await data(ytUploadsURL(ytChannelId: "UCBZ_1wWyLQI3SV9IgLbyiNQ"), resType: YouTubeUploads.self) {
        case .success(let uploadData):
            self.ytUploads = uploadData.videos
            ytUploadsNE = nil
            ytUploadsDTS = .done
        case .failure(let error):
            ytUploadsNE = error
            ytUploadsDTS = .error
        }
    }
    
    func handleURLClick(_ url: URL) -> OpenURLAction.Result {
        let (destination, type) = determineTypeOfURLClick(path: url.relativePath)
        if let destination {
            type == "product" ?  path.append(ProductLinkDestinationValue(productID: destination, productName: "")) : path.append(CardLinkDestinationValue(cardID: destination, cardName: ""))
            return .handled
        }
        return .systemAction
    }
    
    private func determineTypeOfURLClick(path: String) -> (String?, String) {
        if path.contains("/card/") {
            return (path.replacingOccurrences(of: "/card/", with: ""), "card")
        } else if path.contains("/product/") {
            return (path.replacingOccurrences(of: "/product/", with: ""), "product")
        }
        return( nil, "")
    }
}
