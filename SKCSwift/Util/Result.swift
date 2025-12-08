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
            let networkError = NetworkError.fromRPCError(e as? RPCError ?? RPCError(code: .unknown, message: e.localizedDescription), method: method)
            return (networkError, .error)
        }
    }
}
