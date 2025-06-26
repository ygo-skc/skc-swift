//
//  Tag.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/12/25.
//

import SwiftUI

struct TagModifier: ViewModifier {
    let font: Font
    let padding: CGFloat
    
    init(font: Font = .custom("", size: 9, relativeTo: .caption2)) {
        self.font = font
        self.padding = 5
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, padding)
            .padding(.vertical, padding)
            .font(font)
            .fontWeight(.regular)
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.8)]),
                startPoint: .leading,
                endPoint: .trailing
            ))
            .foregroundColor(.white)
            .cornerRadius(6)
            .lineLimit(1)
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
    }
}
