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
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(padding)
            .lineLimit(1)
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
    }
}
