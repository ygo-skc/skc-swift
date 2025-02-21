//
//  ParentViewModifier.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/26/24.
//

import SwiftUI

struct ParentViewModifier: ViewModifier {
    var alignment: Alignment = .topLeading
    
    func body(content: Content) -> some View {
        content
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: alignment
            )
            .padding(.all)
    }
}
