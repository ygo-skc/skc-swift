//
//  SKCAPI.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/3/23.
//

import Foundation

fileprivate func baseRequest(url: URL) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = RequestHelper.GET.description
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(RequestHelper.CLIENT_ID.description, forHTTPHeaderField: "CLIENT_ID")
    request.addValue("keep-alive", forHTTPHeaderField: "Connection")
    
    return request
}

fileprivate func validateResponse(response: URLResponse?, url: URL) throws {
    if let httpResponse = response as? HTTPURLResponse {
        let code = httpResponse.statusCode
        if code <= 201 {
            return
        } else if code == 404 {
            print("URL \(url.absoluteString) does not exist")
            throw DataFetchError.notFound
        } else if code >= 400 && code <= 499 {
            print("URL \(url.absoluteString) returned with 400 level code \(code)")
            throw DataFetchError.client
        } else {
            print("URL \(url.absoluteString) returned with 500 level code \(code)")
            throw DataFetchError.server
        }
    }
}

func data<T>(_ type: T.Type, url: URL) async throws -> T where T : Decodable {
    do {
        let (body, response) = try await URLSession.shared.data(for: baseRequest(url: url))
        try Task.checkCancellation()
        
        try validateResponse(response: response, url: url)
        
        do {
            return try RequestHelper.decoder.decode(type, from: body)
        } catch {
            print("An error occurred while decoding output from http request \(error.localizedDescription)")
            throw DataFetchError.bodyParse
        }
    } catch let error {
        if (error.localizedDescription == "cancelled") {
            throw DataFetchError.cancelled
        }
        
        print("Error occurred while calling \(url.absoluteString) \(error.localizedDescription)")
        throw DataFetchError.unknown
    }
}
