//
//  ParentViewModifier.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/26/24.
//

import SwiftUI

struct ParentViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .padding(.horizontal)
    }
}
