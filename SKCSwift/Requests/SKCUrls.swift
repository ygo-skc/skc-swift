//
//  SKCUrls.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import Foundation

func cardInfoURL(cardId: String) -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = SKC_API_BASE_URL.description
    components.path = "/api/v1/card/\(cardId)"
    
    components.queryItems = [
        URLQueryItem(name: "allInfo", value: "true")
    ]
    
    guard let url = components.url else {
        fatalError("URL is incorrect")
    }
    
    return url
}

func searchCardURL(cardName: String) -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = SKC_API_BASE_URL.description
    components.path = "/api/v1/card/search"
    
    components.queryItems = [
        URLQueryItem(name: "limit", value: "10"),
        URLQueryItem(name: "cName", value: cardName)
    ]
    
    guard let url = components.url else {
        fatalError("URL is incorrect")
    }
    
    return url
}
