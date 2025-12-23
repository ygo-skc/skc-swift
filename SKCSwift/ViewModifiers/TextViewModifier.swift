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
    }
}

extension ViewModifier where Self == HeaderTextModifier {
    static var headerText: HeaderTextModifier { .init() }
}
