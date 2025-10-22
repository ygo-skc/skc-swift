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
            .frame(maxWidth: .infinity)
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

extension ViewModifier where Self == ButtonToggleViewModifier {
    static var buttonToggle: ButtonToggleViewModifier { .init() }
}

extension ViewModifier where Self == ButtonToggleTextViewModifier {
    static var buttonToggleText: ButtonToggleTextViewModifier { .init() }
}
