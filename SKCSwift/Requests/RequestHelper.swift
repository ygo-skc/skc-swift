//
//  Requests.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import Foundation

// common request helpers
struct RequestHelpers {
    static let decoder = JSONDecoder()
}
let GET: StaticString = "GET"
let CLIENT_ID: StaticString = "skc-swift"

func baseRequest(url: URL) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = GET.description
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(CLIENT_ID.description, forHTTPHeaderField: "CLIENT_ID")
    request.addValue("keep-alive", forHTTPHeaderField: "Connection")
    
    return request
}

// SKC API request helpers
let SKC_API_BASE_URL: StaticString = "skc-ygo-api.com"
let SKC_API_SEARCH_ENDPOINT: StaticString = "/api/v1/card/search"
let SKC_API_CARD_INFORMATION_ENDPOINT: StaticString = "/api/v1/card/%@"
let SKC_API_DB_STATS_ENDPOINT: StaticString = "/api/v1/stats"

// SKC Suggestion request helpers
let SKC_SUGGESTION_ENGINE_BASE_URL: StaticString = "suggestions.skc-ygo-api.com"
let SKC_SUGGESTION_ENGINE_CARD_SUGGESTIONS_ENDPOINT: StaticString = "/api/v1/suggestions/card/%@"
let SKC_SUGGESTION_ENGINE_CARD_SUPPORT_ENDPOINT: StaticString = "/api/v1/suggestions/card/%@/support"
let SKC_SUGGESTION_ENGINE_CARD_OF_THE_DAY_ENDPOINT: StaticString = "/api/v1/suggestions/card-of-the-day"

// Heart API request helpers
let HEART_API_BASE_URL: StaticString = "heart-api.com"
let HEART_API_EVENT_ENDPOINT: StaticString = "/api/v1/events"
