//
//  CardColorIndicator.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/23/23.
//

import SwiftUI

struct CardColorIndicator: View {
    var cardColor: String
    var variant: CardColorIndicatorVariant = .regular
    
    var body: some View {
        Circle()
            .if(cardColor.starts(with: "Pendulum")) {
                $0.fill(cardColorGradient(cardColor: cardColor))
            } else: {
                $0.fill(cardColorUI(cardColor: cardColor))
            }
            .modifier(CardColorIndicatorModifier(variant: variant))
    }
}

private struct CardColorIndicatorModifier: ViewModifier {
    var variant: CardColorIndicatorVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .small:
            content
                .frame(width: 15)
        case .regular:
            content
                .frame(width: 18)
        }
    }
}

#Preview("Effect") {
    CardColorIndicator(cardColor: "Effect")
}

#Preview("Pendulum Effect") {
    CardColorIndicator(cardColor: "Pendulum-Effect")
}
