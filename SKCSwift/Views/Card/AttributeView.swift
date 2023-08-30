//
//  AttributeView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/6/23.
//

import SwiftUI

struct AttributeView: View {
    var attribute: Attribute
    
    private static let ICON_SIZE = 30.0
    
    var body: some View {
        if (attribute == .unknown) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .frame(width: AttributeView.ICON_SIZE - 5, height: AttributeView.ICON_SIZE - 5)
        } else {
            Image(attribute.rawValue.lowercased())
                .resizable()
                .frame(width: AttributeView.ICON_SIZE, height: AttributeView.ICON_SIZE)
                .cornerRadius(AttributeView.ICON_SIZE)
        }
    }
}

struct AttributeView_Previews: PreviewProvider {
    static var previews: some View {
        AttributeView(attribute: .light)
            .previewDisplayName("Light")
        AttributeView(attribute: .dark)
            .previewDisplayName("Dark")
        AttributeView(attribute: .earth)
            .previewDisplayName("Earth")
        AttributeView(attribute: .wind)
            .previewDisplayName("Wind")
        AttributeView(attribute: .fire)
            .previewDisplayName("Fire")
        AttributeView(attribute: .water)
            .previewDisplayName("Water")
        AttributeView(attribute: .divine)
            .previewDisplayName("Divine")
        AttributeView(attribute: .spell)
            .previewDisplayName("Spell")
        AttributeView(attribute: .trap)
            .previewDisplayName("Trap")
        AttributeView(attribute: .unknown)
            .previewDisplayName("Attribute cannot be determined")
    }
}
