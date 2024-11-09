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
        case .server: "Network error occurred"
        case .timeout: "Request timeout"
        default: ""
        }
    }
    
    private var icon: String {
        return switch error {
        case .server: "network.slash"
        case .timeout: "clock.badge.xmark"
        default: ""
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
            EmptyView()
        }
    }
}

#Preview("Server Error") {
    NetworkErrorView(error: .server, action: { print("Retried") })
}

#Preview("Timeout") {
    NetworkErrorView(error: .timeout, action: { print("Retried") })
}
