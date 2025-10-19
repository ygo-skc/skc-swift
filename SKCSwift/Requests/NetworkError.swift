//
//  NetworkError.swift
//  SKCSwift
//
//  Created by Javi Gomez on 10/19/25.
//

import Foundation

enum NetworkError: Error {
    case client
    case server
    case badRequest
    case notFound
    case unprocessableEntity
    case reqEncode
    case resDecode
    case cancelled
    case timeout
    case unknown
}

extension NetworkError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .client, .reqEncode:
            return "Client error"
        case .server:
            return "Server error"
        case .badRequest:
            return "400 bad request"
        case .notFound:
            return "404 not found"
        case .unprocessableEntity:
            return "422 unproccessable entity"
        case .resDecode:
            return "Cannot parse body"
        case .cancelled:
            return "Request cancelled by client"
        case .timeout:
            return "Request time out"
        case .unknown:
            return "Unknown"
        }
    }
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .client, .server, .badRequest, .notFound, .unprocessableEntity, .reqEncode, .resDecode, .cancelled, .timeout, .unknown:
            return self.description
        }
    }
}
