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
    private(set) var dataTaskStatus: [HomeModelDataType: DataTaskStatus] = Dictionary(uniqueKeysWithValues: HomeModelDataType.allCases.map { ($0, .uninitiated) })
    private(set) var requestErrors = [HomeModelDataType: NetworkError?]()
    
    @ObservationIgnored
    private(set) var dbStats = SKCDatabaseStats(productTotal: 0, cardTotal: 0, banListTotal: 0)
    @ObservationIgnored
    private(set) var cardOfTheDay = CardOfTheDay(date: "", version: 1, card: Card(cardID: "", cardName: "", cardColor: "", cardAttribute: nil, cardEffect: ""))
    @ObservationIgnored
    private(set) var upcomingTCGProducts = [Event]()
    @ObservationIgnored
    private(set) var ytUploads = [YouTubeVideos]()
    
    var navigationPath = NavigationPath()
    
    var isSettingsSheetPresented = false
    
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
        requestErrors[.dbStats] = nil
        dataTaskStatus[.dbStats] = .pending
        switch await data(dbStatsURL(), resType: SKCDatabaseStats.self) {
        case .success(let dbStats):
            self.dbStats = dbStats
            requestErrors[.dbStats] = nil
        case .failure(let error):
            requestErrors[.dbStats] = error
        }
        dataTaskStatus[.dbStats] = .done
    }
    
    func fetchCardOfTheDayData() async {
        requestErrors[.cardOfTheDay] = nil
        dataTaskStatus[.cardOfTheDay] = .pending
        switch await data(cardOfTheDayURL(), resType: CardOfTheDay.self) {
        case .success(let cardOfTheDay):
            self.cardOfTheDay = cardOfTheDay
            requestErrors[.cardOfTheDay] = nil
        case .failure(let error):
            requestErrors[.cardOfTheDay] = error
        }
        dataTaskStatus[.cardOfTheDay] = .done
    }
    
    func fetchUpcomingTCGProducts() async {
        requestErrors[.upcomingTCGProducts] = nil
        dataTaskStatus[.upcomingTCGProducts] = .pending
        switch await data(upcomingEventsURL(), resType: Events.self) {
        case .success(let upcomingTCGProducts):
            self.upcomingTCGProducts = upcomingTCGProducts.events
            requestErrors[.upcomingTCGProducts] = nil
        case .failure(let error):
            requestErrors[.upcomingTCGProducts] = error
        }
        dataTaskStatus[.upcomingTCGProducts] = .done
    }
    
    func fetchYouTubeUploadsData() async {
        requestErrors[.youtubeUploads] = nil
        dataTaskStatus[.youtubeUploads] = .pending
        switch await data(ytUploadsURL(ytChannelId: "UCBZ_1wWyLQI3SV9IgLbyiNQ"), resType: YouTubeUploads.self) {
        case .success(let uploadData):
            self.ytUploads = uploadData.videos
            requestErrors[.youtubeUploads] = nil
        case .failure(let error):
            requestErrors[.youtubeUploads] = error
        }
        dataTaskStatus[.youtubeUploads] = .done
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
}

enum HomeModelDataType: CaseIterable {
    case dbStats, cardOfTheDay, upcomingTCGProducts, youtubeUploads
}
