//
//  SKCAPI.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/3/23.
//

import Foundation

struct DataTaskStatusParser {
    private static let dataPendingStatuses = [DataTaskStatus.uninitiated, DataTaskStatus.pending]
    
    static func isDataPending(_ status: DataTaskStatus) -> Bool {
        return dataPendingStatuses.contains(status)
    }
}

nonisolated fileprivate struct NilReqBody: Encodable {}

fileprivate let customSession: URLSession = {
    let configuration = URLSessionConfiguration.default
    
    configuration.timeoutIntervalForRequest = 3
    configuration.timeoutIntervalForResource = 5
    configuration.multipathServiceType = .handover
    configuration.requestCachePolicy = .useProtocolCachePolicy
    configuration.allowsCellularAccess = true
    configuration.tlsMinimumSupportedProtocolVersion = .TLSv13
    configuration.httpMaximumConnectionsPerHost = 8
    
    if #available(iOS 26.0, *) {
        configuration.enablesEarlyData = true
    }
    
    configuration.httpAdditionalHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Connection": "keep-alive",
        "User-Agent": "\(RequestHelper.CLIENT_ID.description)/\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "Unknown")",
        "CLIENT_ID": "\(RequestHelper.CLIENT_ID.description)/\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "Unknown")",
        "Accept-Encoding": "gzip, deflate"
    ]
    return URLSession(configuration: configuration)
}()

nonisolated fileprivate func baseRequest(url: URL, httpMethod: String, reqBody: Data?) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod
    request.httpBody = reqBody
    
    return request
}

fileprivate func validateResponse(response: URLResponse?) async throws {
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

@concurrent
func data<U>(_ url: URL, resType: U.Type) async -> Result<U, NetworkError> where U: Decodable {
    await data(url, reqBody: Optional<NilReqBody>.none, resType: resType)
}

@concurrent
func data<T, U>(_ url: URL, reqBody: T? = nil, resType: U.Type, httpMethod: String = "GET") async ->  Result<U, NetworkError> where T: Encodable, U: Decodable {
    do {
        let bodyData = (reqBody == nil) ? nil : try JSONEncoder().encode(reqBody)
        try Task.checkCancellation()
        let (body, response) = try await customSession.data(for: baseRequest(url: url, httpMethod: httpMethod, reqBody: bodyData))
        try Task.checkCancellation()
        try await validateResponse(response: response)
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
