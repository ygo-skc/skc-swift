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
            throw NetworkError.badRequest
        case 404:
            throw NetworkError.notFound
        case 401...499:
            throw NetworkError.client
        default:
            throw NetworkError.server
        }
    }
}

nonisolated func data<T>(_ type: T.Type, url: URL) async -> sending Result<T, NetworkError> where T: Decodable {
    do {
        let (body, response) = try await URLSession.shared.data(for: baseRequest(url: url))
        try Task.checkCancellation()
        
        try validateResponse(response: response, url: url)
        
        return .success(try RequestHelper.decoder.decode(type, from: body))
    } catch let networkError as NetworkError {
        
        print("Error occurred while calling \(url.absoluteString) \(networkError.localizedDescription)")
        return .failure(networkError)
    } catch let error {
        if (error.localizedDescription == "cancelled") {
            return .failure(NetworkError.cancelled)
        }
        
        print("An error occurred while decoding output from http request \(error)")
        return .failure(NetworkError.bodyParse)
    }
}
