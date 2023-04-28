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
        Image(attribute
            .rawValue.lowercased()
        )
        .resizable()
        .frame(width: AttributeView.ICON_SIZE, height: AttributeView.ICON_SIZE)
        .cornerRadius(AttributeView.ICON_SIZE)
    }
}

struct AttributeView_Previews: PreviewProvider {
    static var previews: some View {
        AttributeView(attribute: Attribute(rawValue: "Light")!)
            .previewDisplayName("Light")
        AttributeView(attribute: Attribute(rawValue: "Dark")!)
            .previewDisplayName("Dark")
        AttributeView(attribute: Attribute(rawValue: "Earth")!)
            .previewDisplayName("Earth")
        AttributeView(attribute: Attribute(rawValue: "Wind")!)
            .previewDisplayName("Wind")
        AttributeView(attribute: Attribute(rawValue: "Fire")!)
            .previewDisplayName("Fire")
        AttributeView(attribute: Attribute(rawValue: "Water")!)
            .previewDisplayName("Water")
    }
}
