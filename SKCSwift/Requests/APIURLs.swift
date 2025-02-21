//
//  SKCUrls.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import Foundation

struct RequestHelper {
    // Headers
    static let CLIENT_ID: StaticString = "SKCSwift"
    
    // SKC API request helpers
    static let SKC_API_BASE_URL: StaticString = "skc-ygo-api.com"
    static let SKC_API_CARD_BROWSE_CRITERIA_ENDPOINT: StaticString = "/api/v1/card/browse/criteria"
    static let SKC_API_CARD_BROWSE_ENDPOINT: StaticString = "/api/v1/card/browse"
    static let SKC_API_SEARCH_ENDPOINT: StaticString = "/api/v1/card/search"
    static let SKC_API_CARD_INFORMATION_ENDPOINT: StaticString = "/api/v1/card/%@"
    static let SKC_API_PRODUCT_INFORMATION_ENDPOINT: StaticString = "/api/v1/product/%@/en"
    static let SKC_API_PRODUCTS_ENDPOINT: StaticString = "/api/v1/products/en"
    static let SKC_API_DB_STATS_ENDPOINT: StaticString = "/api/v1/stats"
    static let SKC_API_BAN_LIST_DATES_ENDPOINT: StaticString = "/api/v1/ban_list/dates"
    
    // SKC Suggestion request helpers
    static let SKC_SUGGESTION_ENGINE_BASE_URL: StaticString = "suggestions.skc-ygo-api.com"
    static let SKC_SUGGESTION_ENGINE_CARD_SUGGESTIONS_ENDPOINT: StaticString = "/api/v1/suggestions/card/%@"
    static let SKC_SUGGESTION_ENGINE_CARD_SUPPORT_ENDPOINT: StaticString = "/api/v1/suggestions/card/support/%@"
    static let SKC_SUGGESTION_ENGINE_PRODUCT_SUGGESTIONS_ENDPOINT: StaticString = "/api/v1/suggestions/product/%@"
    static let SKC_SUGGESTION_ENGINE_CARD_OF_THE_DAY_ENDPOINT: StaticString = "/api/v1/suggestions/card-of-the-day"
    static let SKC_SUGGESTION_ENGINE_TRENDING_ENDPOINT: StaticString = "/api/v1/suggestions/trending/%@"
    static let SKC_SUGGESTION_ENGINE_CARD_DETAILS_ENDPOINT: StaticString = "/api/v1/suggestions/card-details"
    
    // Heart API request helpers
    static let HEART_API_BASE_URL: StaticString = "heart-api.com"
    static let HEART_API_EVENT_ENDPOINT: StaticString = "/api/v1/events"
    static let HEART_API_YT_UPLOADS_ENDPOINT: StaticString = "/api/v1/yt/channel/uploads"
}

fileprivate func createURL(components: URLComponents) -> URL {
    guard let url = components.url else {
        fatalError("URL is incorrect")
    }
    return url
}

// SKC API URL creation methods

private func baseURLComponents(host: String, path: String, queryItems: [URLQueryItem] = []) -> URLComponents {
    var components = URLComponents()
    components.scheme = "https"
    components.host = host
    components.path = path
    components.queryItems = queryItems
    
    return components
}

func cardInfoURL(cardID: String) -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_API_BASE_URL.description,
        path: String(format: RequestHelper.SKC_API_CARD_INFORMATION_ENDPOINT.description, cardID),
        queryItems: [URLQueryItem(name: "allInfo", value: "true")]
    )
    
    return createURL(components: components)
}

func productInfoURL(productID: String) -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_API_BASE_URL.description,
        path: String(format: RequestHelper.SKC_API_PRODUCT_INFORMATION_ENDPOINT.description, productID)
    )
    
    return createURL(components: components)
}

func productsURL() -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_API_BASE_URL.description,
        path: RequestHelper.SKC_API_PRODUCTS_ENDPOINT.description
    )
    
    return createURL(components: components)
}

func cardBrowseCriteriaURL() -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_API_BASE_URL.description,
        path: RequestHelper.SKC_API_CARD_BROWSE_CRITERIA_ENDPOINT.description
    )
    return createURL(components: components)
}

func cardBrowseURL(attributes: [String], colors: [String], levels: [String]) -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_API_BASE_URL.description,
        path: RequestHelper.SKC_API_CARD_BROWSE_ENDPOINT.description,
        queryItems: [
            URLQueryItem(name: "attributes", value: attributes.joined(separator: ",")),
            URLQueryItem(name: "cardColors", value: colors.joined(separator: ",")),
            URLQueryItem(name: "levels", value: levels.joined(separator: ","))
        ]
    )
    
    return createURL(components: components)
}

func searchCardURL(cardName: String) -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_API_BASE_URL.description,
        path: RequestHelper.SKC_API_SEARCH_ENDPOINT.description,
        queryItems: cardName.allSatisfy { $0.isNumber } ? [
            URLQueryItem(name: "limit", value: "10"),
            URLQueryItem(name: "cId", value: cardName),
            URLQueryItem(name: "cName", value: cardName)
        ] : [
            URLQueryItem(name: "limit", value: "10"),
            URLQueryItem(name: "cName", value: cardName)
        ]
    )
    
    return createURL(components: components)
}

func dbStatsURL() -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_API_BASE_URL.description,
        path: RequestHelper.SKC_API_DB_STATS_ENDPOINT.description
    )
    return createURL(components: components)
}

func banListDatesURL(format: String) -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_API_BASE_URL.description,
        path: RequestHelper.SKC_API_BAN_LIST_DATES_ENDPOINT.description,
        queryItems: [URLQueryItem(name: "format", value: format)]
    )
    
    return createURL(components: components)
}

// SKC Suggestion Engine URL creation methods

func cardSuggestionsURL(cardID: String) -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_SUGGESTION_ENGINE_BASE_URL.description,
        path: String(format: RequestHelper.SKC_SUGGESTION_ENGINE_CARD_SUGGESTIONS_ENDPOINT.description, cardID)
    )
    return createURL(components: components)
}

func cardSupportURL(cardID: String) -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_SUGGESTION_ENGINE_BASE_URL.description,
        path: String(format: RequestHelper.SKC_SUGGESTION_ENGINE_CARD_SUPPORT_ENDPOINT.description, cardID)
    )
    return createURL(components: components)
}

func productSuggestionsURL(productID: String) -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_SUGGESTION_ENGINE_BASE_URL.description,
        path: String(format: RequestHelper.SKC_SUGGESTION_ENGINE_PRODUCT_SUGGESTIONS_ENDPOINT.description, productID)
    )
    return createURL(components: components)
}

func cardOfTheDayURL() -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_SUGGESTION_ENGINE_BASE_URL.description,
        path: RequestHelper.SKC_SUGGESTION_ENGINE_CARD_OF_THE_DAY_ENDPOINT.description
    )
    return createURL(components: components)
}

func trendingUrl(resource: TrendingResourceType) -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_SUGGESTION_ENGINE_BASE_URL.description,
        path: String(format: RequestHelper.SKC_SUGGESTION_ENGINE_TRENDING_ENDPOINT.description, resource.rawValue)
    )
    return createURL(components: components)
}

func cardDetailsUrl() -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_SUGGESTION_ENGINE_BASE_URL.description,
        path: RequestHelper.SKC_SUGGESTION_ENGINE_CARD_DETAILS_ENDPOINT.description
    )
    return createURL(components: components)
}

// Heart API URL creation methods

func upcomingEventsURL() -> URL {
    let components = baseURLComponents(
        host: RequestHelper.HEART_API_BASE_URL.description,
        path: RequestHelper.HEART_API_EVENT_ENDPOINT.description,
        queryItems: [URLQueryItem(name: "service", value: "skc"), URLQueryItem(name: "tags", value: "product-release")]
    )
    
    return createURL(components: components)
}

func ytUploadsURL(ytChannelId: String) -> URL {
    let components = baseURLComponents(
        host: RequestHelper.HEART_API_BASE_URL.description,
        path: RequestHelper.HEART_API_YT_UPLOADS_ENDPOINT.description,
        queryItems: [URLQueryItem(name: "channelId", value: ytChannelId)]
    )
    
    return createURL(components: components)
}
