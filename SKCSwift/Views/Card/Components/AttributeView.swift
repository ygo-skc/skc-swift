//
//  AttributeView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/6/23.
//

import SwiftUI

struct AttributeView: View, Equatable {
    var attribute: Attribute
    
    private static let ICON_SIZE: CGFloat = 30.0
    
    var body: some View {
        if (attribute == .unknown) {
            Image(systemName: "questionmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: AttributeView.ICON_SIZE - 5, height: AttributeView.ICON_SIZE - 5)
        } else {
            Image(attribute.rawValue.lowercased())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: AttributeView.ICON_SIZE, height: AttributeView.ICON_SIZE)
                .cornerRadius(AttributeView.ICON_SIZE)
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
