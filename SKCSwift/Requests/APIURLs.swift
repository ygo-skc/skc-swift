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

func cardInfoURL(cardId: String) -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = SKC_API_BASE_URL.description
    components.path = String(format: SKC_API_CARD_INFORMATION_ENDPOINT.description, cardId)
    
    components.queryItems = [
        URLQueryItem(name: "allInfo", value: "true")
    ]
    
    return createURL(components: components)
}

func searchCardURL(cardName: String) -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = SKC_API_BASE_URL.description
    components.path = SKC_API_SEARCH_ENDPOINT.description
    
    components.queryItems = [
        URLQueryItem(name: "limit", value: "10"),
        URLQueryItem(name: "cName", value: cardName)
    ]
    
    return createURL(components: components)
}

// SKC Suggestion Engine URL creation methods

func cardSuggestionsURL(cardId: String) -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = SKC_SUGGESTION_ENGINE_BASE_URL.description
    components.path = String(format: SKC_SUGGESTION_ENGINE_CARD_SUGGESTIONS_ENDPOINT.description, cardId)
    
    return createURL(components: components)
}

func cardSupportURL(cardId: String) -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = SKC_SUGGESTION_ENGINE_BASE_URL.description
    components.path = String(format: SKC_SUGGESTION_ENGINE_CARD_SUPPORT_ENDPOINT.description, cardId)
    
    return createURL(components: components)
}
