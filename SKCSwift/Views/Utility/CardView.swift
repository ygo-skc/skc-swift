//
//  CardView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 10/17/25.
//

import SwiftUI

struct CardView<Content: View>: View {
    let minWidth: CGFloat?
    let maxWidth: CGFloat
    let content: Content
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(
        minWidth: CGFloat? = nil,
        maxWidth: CGFloat = 200,
        @ViewBuilder content: () -> Content
    ) {
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            content
        }
        .padding()
        .modifier(.card)
        .frame(minWidth: minWidth, maxWidth: maxWidth, alignment: .topLeading)
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
