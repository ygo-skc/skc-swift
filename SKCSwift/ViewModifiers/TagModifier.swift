//
//  Tag.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/12/25.
//

import SwiftUI

struct TagModifier: ViewModifier {
    let font: Font
    
    init(font: Font = .caption) {
        self.font = font
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .font(font)
            .fontWeight(.semibold)
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.8)]),
                startPoint: .leading,
                endPoint: .trailing
            ))
            .foregroundColor(.white)
            .cornerRadius(6)
            .lineLimit(1)
            .dynamicTypeSize(...DynamicTypeSize.medium)
    }
}
