//
//  CardColorIndicator.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/23/23.
//

import SwiftUI

struct CardColorIndicatorView: View, Equatable {
    let cardColor: String
    let variant: CardColorIndicatorVariant
    
    init(cardColor: String, variant: CardColorIndicatorVariant = .regular) {
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
            .modifier(CardColorIndicatorViewModifier(variant: variant))
    }
}

private struct CardColorIndicatorViewModifier: ViewModifier {
    var variant: CardColorIndicatorVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .small:
            content
                .frame(width: 15)
        case .regular:
            content
                .frame(width: 18)
        case .large:
            content
                .frame(width: 30)
        }
    }
}

#Preview("Effect") {
    CardColorIndicatorView(cardColor: "Effect")
}

#Preview("Pendulum Effect") {
    CardColorIndicatorView(cardColor: "Pendulum-Effect")
}
