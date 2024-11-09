//
//  NetworkError.swift
//  SKCSwift
//
//  Created by Javi Gomez on 11/8/24.
//

import SwiftUI

struct NetworkErrorView: View {
    var status: DataTaskStatus
    var action: () -> Void
    
    private var description: String {
        return switch status {
        case .error: "Network error occurred"
        case .timeout: "Request timeout"
        default: ""
        }
    }
    
    private var icon: String {
        return switch status {
        case .error: "network.slash"
        case .timeout: "clock.badge.xmark"
        default: ""
        }
    }
    
    var body: some View {
        switch status {
        case .error, .timeout:
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

#Preview("Generic Error") {
    NetworkErrorView(status: .error, action: { print("Retried") })
}

#Preview("Timeout") {
    NetworkErrorView(status: .timeout, action: { print("Retried") })
}
