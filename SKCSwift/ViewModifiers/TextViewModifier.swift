//
//  TextViewModifier.swift
//  SKCSwift
//
//  Created by Javi Gomez on 12/22/25.
//

import SwiftUI

struct HeaderTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .fontWeight(.bold)
            .padding(.bottom, 8)
    }
}

extension View {
    func headerTextModifier(hasPadding: Bool = true) -> some View {
        modifier(HeaderTextModifier())
    }
}
