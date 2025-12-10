//
//  CardView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 10/17/25.
//

import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            content
                .frame(alignment: .topLeading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.2), lineWidth: 1)
        )
        .frame(maxWidth: 200, alignment: .topLeading)
    }
}

#Preview {
    CardView {
        Group {
            Label("897 day(s)", systemImage: "1.circle")
                .font(.callout)
                .padding(.bottom, 4)
            Text("Since last printing")
                .font(.callout)
                .padding(.bottom, 2)
        }
    }
}
