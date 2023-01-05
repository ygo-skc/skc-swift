//
//  Requests.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import Foundation

let SKC_API_BASE_URL: StaticString = "skc-ygo-api.com"

func baseSKCAPIRequest(url: URL) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("skc-swift", forHTTPHeaderField: "CLIENT_ID")
    
    return request
}
