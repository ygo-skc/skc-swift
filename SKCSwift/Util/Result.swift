//
//  Result.swift
//  SKCSwift
//
//  Created by Javi Gomez on 11/23/25.
//

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
