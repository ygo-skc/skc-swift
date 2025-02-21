//
//  SKCAPI.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/3/23.
//

import Foundation

fileprivate struct NilReqBody: Encodable {}

fileprivate func baseRequest(url: URL, httpMethod: String, reqBody: Data?) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod
    request.httpBody = reqBody
    request.addValue(RequestHelper.CLIENT_ID.description, forHTTPHeaderField: "CLIENT_ID")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("keep-alive", forHTTPHeaderField: "Connection")
    request.addValue("gzip", forHTTPHeaderField: "Accept-Encoding")
    
    request.timeoutInterval = 5
    return request
}

fileprivate func validateResponse(response: URLResponse?) throws {
    if let httpResponse = response as? HTTPURLResponse {
        let code = httpResponse.statusCode
        switch code {
        case 0...399:
            return
        case 400:
            throw NetworkError.badRequest
        case 404:
            throw NetworkError.notFound
        case 422:
            throw NetworkError.unprocessableEntity
        case 401...499:
            throw NetworkError.client
        default:
            throw NetworkError.server
        }
    }
}

nonisolated func data<U>(_ url: URL, resType: U.Type) async -> sending Result<U, NetworkError> where U: Decodable {
    await data(url, reqBody: Optional<NilReqBody>.none, resType: resType)
}

nonisolated func data<T, U>(_ url: URL, reqBody: T? = nil, resType: U.Type, httpMethod: String = "GET") async -> sending Result<U, NetworkError> where T: Encodable, U: Decodable {
    do {
        let bodyData = (reqBody == nil) ? nil : try JSONEncoder().encode(reqBody)
        let (body, response) = try await URLSession.shared.data(for: baseRequest(url: url, httpMethod: httpMethod, reqBody: bodyData))
        try Task.checkCancellation()
        try validateResponse(response: response)
        return .success(try JSONDecoder().decode(resType, from: body))
    } catch let networkError as NetworkError {
        print("Error occurred while calling \(url.absoluteString) \(networkError.localizedDescription)")
        return .failure(networkError)
    } catch let urlError as URLError {
        switch urlError.code {
        case .cancelled:
            return .failure(NetworkError.cancelled)
        case .timedOut:
            print("Request timed out for url: \(url.absoluteString)")
            return .failure(NetworkError.timeout)
        case .badServerResponse, .cannotDecodeContentData, .cannotParseResponse:
            print("Server responded with bad data for url: \(url.absoluteString)")
            return .failure(NetworkError.resDecode)
        default:
            print("Unknown URLError occurred while calling \(url.absoluteString) - error: \(urlError)")
            return .failure(NetworkError.unknown)
        }
    } catch let decodeError as DecodingError {
        print("Error decoding output for url: \(url.absoluteString) - error: \(decodeError)")
        return .failure(NetworkError.resDecode)
    } catch let encodeError as EncodingError {
        print("Error encoding request body for url: \(url.absoluteString) - error: \(encodeError)")
        return .failure(NetworkError.reqEncode)
    } catch let error {
        print("Unknown error occurred while calling \(url.absoluteString) - error: \(error)")
        return .failure(NetworkError.unknown)
    }
}
