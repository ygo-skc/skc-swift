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
    
    init(font: Font = .caption) {
        self.font = font
        
        if font == .caption {
            self.padding = 4
        } else {
            padding = 6
        }
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, padding)
            .padding(.vertical, padding)
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
