//
//  AttributeView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/6/23.
//

import SwiftUI

struct AttributeView: View, Equatable {
    var attribute: Attribute
    var variant: IconVariant
    
    init(attribute: Attribute, variant: IconVariant = .large) {
        self.attribute = attribute
        self.variant = variant
    }
    
    var body: some View {
        if (attribute == .unknown) {
            Image(systemName: "questionmark.circle.fill")
                .resizable()
                .modifier(IconViewModifier(variant: variant))
        } else {
            Image(attribute.rawValue.lowercased())
                .resizable()
                .modifier(IconViewModifier(variant: variant))
        }
    }
}

#Preview("Light") {
    AttributeView(attribute: .light)
}

#Preview("Dark") {
    AttributeView(attribute: .dark)
}

#Preview("Earth") {
    AttributeView(attribute: .earth)
}

#Preview("Wind") {
    AttributeView(attribute: .wind)
}

#Preview("Fire") {
    AttributeView(attribute: .fire)
}

#Preview("Water") {
    AttributeView(attribute: .water)
}

#Preview("Divine") {
    AttributeView(attribute: .divine)
}

#Preview("Spell") {
    AttributeView(attribute: .spell)
}

#Preview("Trap") {
    AttributeView(attribute: .trap)
}

#Preview("Unkown Attribute") {
    AttributeView(attribute: .unknown)
}
