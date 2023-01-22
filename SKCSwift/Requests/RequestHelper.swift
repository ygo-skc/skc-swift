//
//  Requests.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import Foundation

// common request helpers
let decoder = JSONDecoder()
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

// SKC Suggestion request helpers
let SKC_SUGGESTION_ENGINE_BASE_URL: StaticString = "suggestions.skc-ygo-api.com"
