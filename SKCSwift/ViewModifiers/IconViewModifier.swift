//
//  IconViewModifier.swift
//  SKCSwift
//
//  Created by Javi Gomez on 2/6/25.
//

import SwiftUI

struct IconViewModifier: ViewModifier {
    var variant: IconVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .small:
            content
                .aspectRatio(contentMode: .fit)
                .frame(width: 16)
        case .regular:
            content
                .aspectRatio(contentMode: .fit)
                .frame(width: 23)
        case .large:
            content
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
        }
    }
}


enum IconVariant {
    case small
    case regular
    case large
}
