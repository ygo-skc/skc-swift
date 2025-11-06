//
//  SKCUrls.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import Foundation

nonisolated struct RequestHelper {
    // Headers
    static let CLIENT_ID: StaticString = "SKCSwift"
    
    // SKC API request helpers
    fileprivate static let SKC_API_BASE_URL: StaticString = "skc-ygo-api.com"
    fileprivate static let SKC_API_CARD_BROWSE_CRITERIA_ENDPOINT: StaticString = "/api/v1/card/browse/criteria"
    fileprivate static let SKC_API_CARD_BROWSE_ENDPOINT: StaticString = "/api/v1/card/browse"
    fileprivate static let SKC_API_SEARCH_ENDPOINT: StaticString = "/api/v1/card/search"
    fileprivate static let SKC_API_CARD_INFORMATION_ENDPOINT: StaticString = "/api/v1/card/%@"
    fileprivate static let SKC_API_PRODUCT_INFORMATION_ENDPOINT: StaticString = "/api/v1/product/%@/en"
    fileprivate static let SKC_API_PRODUCTS_ENDPOINT: StaticString = "/api/v1/products/en"
    fileprivate static let SKC_API_DB_STATS_ENDPOINT: StaticString = "/api/v1/stats"
    fileprivate static let SKC_API_BAN_LIST_DATES_ENDPOINT: StaticString = "/api/v1/ban_list/dates"
    fileprivate static let SKC_API_BAN_LIST_CONTENTS_ENDPOINT: StaticString = "/api/v1/ban_list/%@/cards"
    
    // SKC Suggestion request helpers
    fileprivate static let SKC_SUGGESTION_ENGINE_BASE_URL: StaticString = "suggestions.skc-ygo-api.com"
    fileprivate static let SKC_SUGGESTION_ENGINE_BATCH_CARD_SUGGESTIONS_ENDPOINT: StaticString = "/api/v1/suggestions/card"
    fileprivate static let SKC_SUGGESTION_ENGINE_BATCH_CARD_SUPPORT_ENDPOINT: StaticString = "/api/v1/suggestions/card/support"
    fileprivate static let SKC_SUGGESTION_ENGINE_CARD_SUGGESTIONS_ENDPOINT: StaticString = "/api/v1/suggestions/card/%@"
    fileprivate static let SKC_SUGGESTION_ENGINE_CARD_SUPPORT_ENDPOINT: StaticString = "/api/v1/suggestions/card/support/%@"
    fileprivate static let SKC_SUGGESTION_ENGINE_PRODUCT_SUGGESTIONS_ENDPOINT: StaticString = "/api/v1/suggestions/product/%@"
    fileprivate static let SKC_SUGGESTION_ENGINE_CARD_OF_THE_DAY_ENDPOINT: StaticString = "/api/v1/suggestions/card-of-the-day"
    fileprivate static let SKC_SUGGESTION_ENGINE_TRENDING_ENDPOINT: StaticString = "/api/v1/suggestions/trending/%@"
    fileprivate static let SKC_SUGGESTION_ENGINE_CARD_DETAILS_ENDPOINT: StaticString = "/api/v1/suggestions/card-details"
    
    // Heart API request helpers
    fileprivate static let HEART_API_BASE_URL: StaticString = "heart-api.com"
    fileprivate static let HEART_API_EVENT_ENDPOINT: StaticString = "/api/v1/events"
    fileprivate static let HEART_API_YT_UPLOADS_ENDPOINT: StaticString = "/api/v1/yt/channel/uploads"
}

fileprivate func createURL(components: URLComponents) -> URL {
    guard let url = components.url else {
        fatalError("URL is incorrect")
    }
    return url
}

// SKC API URL creation methods

fileprivate func baseURLComponents(host: String, path: String, queryItems: [URLQueryItem] = []) -> URLComponents {
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

func cardBrowseURL(attributes: [String], colors: [String], monsterTypes: [String],
                               levels: [String], ranks: [String], linkRatings: [String]) -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_API_BASE_URL.description,
        path: RequestHelper.SKC_API_CARD_BROWSE_ENDPOINT.description,
        queryItems: [
            URLQueryItem(name: "attributes", value: attributes.joined(separator: ",")),
            URLQueryItem(name: "cardColors", value: colors.joined(separator: ",")),
            URLQueryItem(name: "monsterTypes", value: monsterTypes.joined(separator: ",")),
            URLQueryItem(name: "levels", value: levels.joined(separator: ",")),
            URLQueryItem(name: "ranks", value: ranks.joined(separator: ",")),
            URLQueryItem(name: "linkRatings", value: linkRatings.joined(separator: ","))
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

func banListDatesURL(format: CardRestrictionFormat) -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_API_BASE_URL.description,
        path: RequestHelper.SKC_API_BAN_LIST_DATES_ENDPOINT.description,
        queryItems: [URLQueryItem(name: "format", value: "\(format)")]
    )
    
    return createURL(components: components)
}

func bannedContentURL(format: CardRestrictionFormat, listStartDate: String, saveBandwidth: Bool, allInfo: Bool) -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_API_BASE_URL.description,
        path: String(format: RequestHelper.SKC_API_BAN_LIST_CONTENTS_ENDPOINT.description, listStartDate),
        queryItems: [
            URLQueryItem(name: "saveBandwidth", value: "\(saveBandwidth)"),
            URLQueryItem(name: "allInfo", value: "\(allInfo)"),
            URLQueryItem(name: "format", value: "\(format)")
        ]
    )
    
    return createURL(components: components)
}

// SKC Suggestion Engine URL creation methods

func batchCardSuggestionsURL() -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_SUGGESTION_ENGINE_BASE_URL.description,
        path: RequestHelper.SKC_SUGGESTION_ENGINE_BATCH_CARD_SUGGESTIONS_ENDPOINT.description
    )
    return createURL(components: components)
}

func batchCardSupportURL() -> URL {
    let components = baseURLComponents(
        host: RequestHelper.SKC_SUGGESTION_ENGINE_BASE_URL.description,
        path: RequestHelper.SKC_SUGGESTION_ENGINE_BATCH_CARD_SUPPORT_ENDPOINT.description
    )
    return createURL(components: components)
}

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
