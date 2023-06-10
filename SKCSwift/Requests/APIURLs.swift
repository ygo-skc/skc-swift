//
//  SKCUrls.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import Foundation

private func createURL(components: URLComponents) -> URL {
    guard let url = components.url else {
        fatalError("URL is incorrect")
    }
    return url
}

// SKC API URL creation methods

private func baseURLComponents(host: String, path: String) -> URLComponents {
    var components = URLComponents()
    components.scheme = "https"
    components.host = host
    components.path = path
    
    return components
}

func cardInfoURL(cardID: String) -> URL {
    var components = baseURLComponents(
        host: SKC_API_BASE_URL.description,
        path: String(format: SKC_API_CARD_INFORMATION_ENDPOINT.description, cardID)
    )
    components.queryItems = [
        URLQueryItem(name: "allInfo", value: "true")
    ]
    
    return createURL(components: components)
}

func searchCardURL(cardName: String) -> URL {
    var components = baseURLComponents(
        host: SKC_API_BASE_URL.description,
        path: SKC_API_SEARCH_ENDPOINT.description
    )
    components.queryItems = [
        URLQueryItem(name: "limit", value: "10"),
        URLQueryItem(name: "cName", value: cardName)
    ]
    
    return createURL(components: components)
}

func dbStatsURL() -> URL {
    let components = baseURLComponents(
        host: SKC_API_BASE_URL.description,
        path: SKC_API_DB_STATS_ENDPOINT.description
    )
    return createURL(components: components)
}

// SKC Suggestion Engine URL creation methods

func cardSuggestionsURL(cardID: String) -> URL {
    let components = baseURLComponents(
        host: SKC_SUGGESTION_ENGINE_BASE_URL.description,
        path: String(format: SKC_SUGGESTION_ENGINE_CARD_SUGGESTIONS_ENDPOINT.description, cardID)
    )
    return createURL(components: components)
}

func cardSupportURL(cardID: String) -> URL {
    let components = baseURLComponents(
        host: SKC_SUGGESTION_ENGINE_BASE_URL.description,
        path: String(format: SKC_SUGGESTION_ENGINE_CARD_SUPPORT_ENDPOINT.description, cardID)
    )
    return createURL(components: components)
}

func cardOfTheDayURL() -> URL {
    let components = baseURLComponents(
        host: SKC_SUGGESTION_ENGINE_BASE_URL.description,
        path: SKC_SUGGESTION_ENGINE_CARD_OF_THE_DAY_ENDPOINT.description
    )
    return createURL(components: components)
}

// Heart API URL creation methods

func upcomingEventsURL() -> URL {
    var components = baseURLComponents(
        host: HEART_API_BASE_URL.description,
        path: HEART_API_EVENT_ENDPOINT.description
    )
    components.queryItems = [
        URLQueryItem(name: "service", value: "skc"),
        URLQueryItem(name: "tags", value: "product-release")
    ]
    
    return createURL(components: components)
}

func ytUploadsURL(ytChannelId: String) -> URL {
    var components = baseURLComponents(
        host: HEART_API_BASE_URL.description,
        path: HEART_API_YT_UPLOADS_ENDPOINT.description
    )
    components.queryItems = [
        URLQueryItem(name: "channelId", value: ytChannelId)
    ]
    
    return createURL(components: components)
}
