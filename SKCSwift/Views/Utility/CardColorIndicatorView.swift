//
//  CardColorIndicator.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/23/23.
//

import SwiftUI

struct CardColorIndicatorView: View, Equatable {
    let cardColor: String
    let variant: IconVariant
    
    init(cardColor: String, variant: IconVariant = .regular) {
        self.cardColor = cardColor
        self.variant = variant
    }
    
    var body: some View {
        Circle()
            .if(cardColor.starts(with: "Pendulum")) {
                $0.fill(cardColorGradient(cardColor: cardColor))
            } else: {
                $0.fill(cardColorUI(cardColor: cardColor))
            }
            .modifier(IconViewModifier(variant: variant))
    }
}

#Preview("Effect") {
    CardColorIndicatorView(cardColor: "Effect")
}

#Preview("Pendulum Effect") {
    CardColorIndicatorView(cardColor: "Pendulum-Effect")
}
