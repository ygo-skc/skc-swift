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

    nonisolated func validate(_ d: inout Success?) -> (NetworkError?, DataTaskStatus) {
        switch self {
        case .success(let value):
            d = value
            return (nil, .done)
        case .failure(let e):
            return (e, .error)
        }
    }

    nonisolated func validate<T>(_ d: inout T, keyPath: KeyPath<Success, T>) -> (NetworkError?, DataTaskStatus) {
        switch self {
        case .success(let value):
            d = value[keyPath: keyPath]
            return (nil, .done)
        case .failure(let e):
            return (e, .error)
        }
    }
}

extension Result where Success: Decodable, Failure: Error {
    nonisolated func validate(method: String) -> (NetworkError?, DataTaskStatus) {
        switch self {
        case .success(_):
            return (nil, .done)
        case .failure(let e):
            return (Self.networkError(from: e, method: method), .error)
        }
    }

    nonisolated func validate(_ d: inout Success?, method: String) -> (NetworkError?, DataTaskStatus) {
        switch self {
        case .success(let value):
            d = value
            return (nil, .done)
        case .failure(let e):
            return (Self.networkError(from: e, method: method), .error)
        }
    }

    nonisolated func validate<T>(_ d: inout T, keyPath: KeyPath<Success, T>, method: String) -> (NetworkError?, DataTaskStatus) {
        switch self {
        case .success(let value):
            d = value[keyPath: keyPath]
            return (nil, .done)
        case .failure(let e):
            return (Self.networkError(from: e, method: method), .error)
        }
    }

    nonisolated private static func networkError(from e: Failure, method: String) -> NetworkError {
        if case let rpcError as RPCError = e {
            return NetworkError.fromRPCError(rpcError, method: method)
        } else if case let cancellationError as CancellationError = e {
            return NetworkError.fromRPCError(RPCError(code: .deadlineExceeded, message: cancellationError.localizedDescription), method: method)
        } else {
            return NetworkError.fromRPCError(RPCError(code: .unknown, message: e.localizedDescription), method: method)
        }
    }
}
