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
    
    init(font: Font = .custom("", size: 10, relativeTo: .caption2)) {
        self.font = font
        self.padding = 5
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.all, padding)
            .font(font)
            .fontWeight(.semibold)
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.8)]),
                startPoint: .leading,
                endPoint: .trailing
            ))
            .foregroundColor(.white)
            .cornerRadius(padding)
            .lineLimit(1)
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
    }
}
