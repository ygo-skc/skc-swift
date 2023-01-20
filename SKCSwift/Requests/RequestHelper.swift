//
//  Requests.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import Foundation

let SKC_API_BASE_URL: StaticString = "skc-ygo-api.com"
let GET: StaticString = "GET"
let CONTENT_TYPE: StaticString = "application/json"
let CLIENT_ID: StaticString = "skc-swift"

let skcAPIDecoder = JSONDecoder()

func baseSKCAPIRequest(url: URL) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = GET.description
    request.addValue(CONTENT_TYPE.description, forHTTPHeaderField: "Content-Type")
    request.addValue(CLIENT_ID.description, forHTTPHeaderField: "CLIENT_ID")
    
    return request
}
