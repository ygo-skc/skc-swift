//
//  NetworkError.swift
//  SKCSwift
//
//  Created by Javi Gomez on 11/8/24.
//

import SwiftUI

struct NetworkErrorView: View {
    var error: NetworkError
    var action: () -> Void
    
    private var description: String {
        return switch error {
        case .server: "Server ran into an issue while processing your request"
        case .timeout: "Request timed out"
        case .client, .unknown: "Error occurred while fetching data"
        case .badRequest, .unprocessableEntity: "Request could not be processed"
        case .notFound: "Resource does not exist"
        case .bodyParse: "Error decoding request"
        case .cancelled: "Request was cancelled before completion"
        }
    }
    
    private var icon: String {
        return switch error {
        case .server: "network.slash"
        case .timeout: "clock.badge.xmark"
        case .client, .badRequest, .unprocessableEntity, .bodyParse, .unknown: "exclamationmark.circle"
        case .notFound, .cancelled: "nosign"
        }
    }
    
    var body: some View {
        switch error {
        case .server, .timeout:
            ContentUnavailableView {
                Label(description, systemImage: icon)
            } description: {
                Button(action: action) {
                    Label("Retry", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
            }
        default:
            ContentUnavailableView {Label(description, systemImage: icon)}
        }
    }
}

#Preview("Server Error") {
    NetworkErrorView(error: .server, action: { print("Retried") })
}

#Preview("Client Error") {
    NetworkErrorView(error: .client, action: { print("Retried") })
}

#Preview("Bad Request Error") {
    NetworkErrorView(error: .badRequest, action: { print("Retried") })
}

#Preview("Unproccessible Entity Error") {
    NetworkErrorView(error: .unprocessableEntity, action: { print("Retried") })
}

#Preview("Not Found Error") {
    NetworkErrorView(error: .notFound, action: { print("Retried") })
}

#Preview("Body Parse Error") {
    NetworkErrorView(error: .bodyParse, action: { print("Retried") })
}

#Preview("Cancelled") {
    NetworkErrorView(error: .cancelled, action: { print("Retried") })
}

#Preview("Timeout") {
    NetworkErrorView(error: .timeout, action: { print("Retried") })
}

#Preview("Unknown") {
    NetworkErrorView(error: .unknown, action: { print("Retried") })
}
