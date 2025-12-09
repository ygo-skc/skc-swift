//
//  Result.swift
//  SKCSwift
//
//  Created by Javi Gomez on 11/23/25.
//
import SwiftUI
import GRPCCore

extension Result where Success: Decodable, Failure == NetworkError {
    nonisolated func validate() -> (NetworkError?, DataTaskStatus) {
        switch self {
        case .success(_):
            return (nil, .done)
        case .failure(let e):
            return (e, .error)
        }
    }
}

extension Result where Success: Decodable, Failure == any Error {
    nonisolated func validate(method: String) -> (NetworkError?, DataTaskStatus) {
        switch self {
        case .success(_):
            return (nil, .done)
        case .failure(let e):
            if case let rpcError as RPCError = e {
                return (NetworkError.fromRPCError(rpcError, method: method), .error)
            } else if case let cancellationError as CancellationError = e {
                return (NetworkError.fromRPCError(RPCError(code: .deadlineExceeded, message: cancellationError.localizedDescription), method: method), .error)
            } else {
                return (NetworkError.fromRPCError(RPCError(code: .unknown, message: e.localizedDescription), method: method), .error)
            }
        }
    }
}
