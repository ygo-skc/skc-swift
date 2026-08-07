//
//  NetworkError.swift
//  SKCSwift
//
//  Created by Javi Gomez on 10/19/25.
//

import Foundation
import GRPCCore
import os

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
    
    static func fromRPCError(_ rpcError: RPCError, method: String) -> NetworkError {
        switch rpcError.code {
        case .cancelled, .aborted, .dataLoss:
            Logger.network.debug("RPC \(method, privacy: .public) call cancelled. Message: \(rpcError.message, privacy: .public)")
            return .cancelled
        case .unknown:
            Logger.network.error("RPC \(method, privacy: .public) call resulted in unknown error. Message: \(rpcError.message, privacy: .public)")
            return .unknown
        case .deadlineExceeded:
            Logger.network.error("RPC \(method, privacy: .public) call timed out. Message: \(rpcError.message, privacy: .public)")
            return .timeout
        case .invalidArgument, .alreadyExists:
            Logger.network.error("RPC \(method, privacy: .public) call failed due to invalid request. Message: \(rpcError.message, privacy: .public)")
            return .badRequest
        case .notFound, .unimplemented:
            Logger.network.error("RPC \(method, privacy: .public) call resulted in not found error. Message: \(rpcError.message, privacy: .public)")
            return .notFound
        case .permissionDenied, .unauthenticated:
            Logger.network.error("RPC \(method, privacy: .public) call resulted in authentication error. Message: \(rpcError.message, privacy: .public)")
            return .client
        case .failedPrecondition, .outOfRange:
            Logger.network.error("RPC \(method, privacy: .public) call failed due to unprocessable entity. Message: \(rpcError.message, privacy: .public)")
            return .unprocessableEntity
        case .unimplemented, .unavailable, .internalError, .resourceExhausted:
            Logger.network.error("RPC \(method, privacy: .public) call resulted in server error. Message: \(rpcError.message, privacy: .public)")
            return .server
        default:
            Logger.network.error("RPC \(method, privacy: .public) call resulted in unknown error.")
            return .unknown
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .client, .server, .badRequest, .notFound, .unprocessableEntity, .reqEncode, .resDecode, .cancelled, .timeout, .unknown:
            return self.description
        }
    }
    
    var description: String {
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
