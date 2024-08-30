//
//  DownstreamErrorView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/29/24.
//

import SwiftUI

struct DownstreamErrorView: View {
    let label: String
    let description: String
    let systemImage: String
    let canRefresh: Bool
    let onRefresh: () -> Void
    
    var body: some View {
        Group {
            ContentUnavailableView(label, systemImage: systemImage, description: Text(description))
            
            if canRefresh {
                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

#Preview("Cannot Retry") {
    DownstreamErrorView(label: "Card not currently supported",
                        description: "Please check back later",
                        systemImage: "exclamationmark.square.fill",
                        canRefresh: false) {}
}

#Preview("Can Retry") {
    DownstreamErrorView(label: "Card not currently supported",
                        description: "Please check back later",
                        systemImage: "exclamationmark.square.fill",
                        canRefresh: true) {}
}
