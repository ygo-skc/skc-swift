//
//  NetworkError.swift
//  SKCSwift
//
//  Created by Javi Gomez on 10/19/25.
//

import Foundation
import GRPCCore

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
    
    /*
     */
    
    static func fromRPCError(_ rpcError: RPCError, method: String) -> NetworkError {
        print("YOOO")
        switch rpcError.code {
        case .cancelled, .aborted, .dataLoss, .deadlineExceeded:
            print("RPC \(method) call cancelled. Message: \(rpcError.message)")
            return .cancelled
        case .unknown:
            print("RPC \(method) call resulted in unknown error. Message: \(rpcError.message)")
            return .unknown
        case .deadlineExceeded:
            print("RPC \(method) call timed out. Message: \(rpcError.message)")
            return .timeout
        case .invalidArgument, .alreadyExists:
            print("RPC \(method) call failed due to invalid request. Message: \(rpcError.message)")
            return .badRequest
        case .notFound, .unimplemented:
            print("RPC \(method) call resulted in not found error. Message: \(rpcError.message)")
            return .notFound
        case .permissionDenied, .unauthenticated:
            print("RPC \(method) call resulted in authentication error. Message: \(rpcError.message)")
            return .client
        case .failedPrecondition, .outOfRange:
            print("RPC \(method) call failed due to unprocessable entity. Message: \(rpcError.message)")
            return .unprocessableEntity
        case .unimplemented, .unavailable, .internalError, .resourceExhausted:
            print("RPC \(method) call resulted in server error. Message: \(rpcError.message)")
            return .server
        default:
            print("RPC \(method) call resulted in unknown error.")
            return .unknown
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .client, .server, .badRequest, .notFound, .unprocessableEntity, .reqEncode, .resDecode, .cancelled, .timeout, .unknown:
            return self.description
        }
    }
    
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

func handleRPCError(method: String, error: RPCError) {
    switch error.code {
    case .notFound:
        print("RPC \(method) call resulted in not found error. Message: \(error.message)")
    default:
        print("RPC error \(error.message)")
    }
}
