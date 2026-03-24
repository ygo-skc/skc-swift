//
//  SummaryBarLink.swift
//  SKCSwift
//
//  Created by Javi Gomez on 3/23/26.
//
import SwiftUI

struct SummaryBarLink<P: Hashable>: View {
    private let description: String?
    private let systemImage: String?
    private let trailingText: String
    private let value: P
    
    init(_ description: String, systemImage: String, trailingText: String = "More", value: P) {
        self.description = description
        self.systemImage = systemImage
        self.trailingText = trailingText
        self.value = value
    }
    
    init(trailingText: String = "More", value: P) {
        self.description = nil
        self.systemImage = nil
        self.trailingText = trailingText
        self.value = value
    }
    
    var body: some View {
        NavigationLink(value: value) {
            HStack {
                if let description, let systemImage {
                    Label(description, systemImage: systemImage)
                        .font(.headline)
                }
                Spacer()
                Text("More")
                    .font(.headline)
                    .fontWeight(.light)
                Image(systemName: "chevron.forward")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
