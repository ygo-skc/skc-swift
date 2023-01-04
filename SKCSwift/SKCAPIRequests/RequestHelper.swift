//
//  Requests.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import Foundation

let BASE_URL: StaticString = "https://skc-ygo-api.com"

func basicSKCRequest(url: URL) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("skc-swift", forHTTPHeaderField: "CLIENT_ID")
    
    return request
}
