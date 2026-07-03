//
//  ToggleViewModifier.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/23/24.
//

import SwiftUI

struct ButtonToggleViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toggleStyle(.button)
            .tint(.primary)
    }
}

struct ButtonToggleTextViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
    }
}

extension View {
    func buttonToggleModifier() -> some View {
        modifier(ButtonToggleViewModifier())
    }
    
    func buttonToggleTextModifier() -> some View {
        modifier(ButtonToggleTextViewModifier())
    }
}

