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
        switch code {
        case 0...399:
            return
        case 400:
            throw DataFetchError.client
        case 404:
            throw DataFetchError.notFound
        case 401...499:
            throw DataFetchError.client
        default:
            throw DataFetchError.server
        }
    }
}

func data<T>(_ type: T.Type, url: URL) async throws -> T where T : Decodable {
    do {
        let (body, response) = try await URLSession.shared.data(for: baseRequest(url: url))
        try Task.checkCancellation()
        
        try validateResponse(response: response, url: url)
        
        return try RequestHelper.decoder.decode(type, from: body)
    } catch let error as DataFetchError {
        if (error.localizedDescription == "cancelled") {
            throw DataFetchError.cancelled
        }
        
        print("Error occurred while calling \(url.absoluteString) \(error.localizedDescription)")
        throw DataFetchError.unknown
    } catch {
        print("An error occurred while decoding output from http request \(error)")
        throw DataFetchError.bodyParse
    }
}
