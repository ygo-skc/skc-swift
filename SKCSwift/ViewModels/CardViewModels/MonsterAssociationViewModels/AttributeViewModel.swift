//
//  AttributeViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/6/23.
//

import SwiftUI

struct AttributeViewModel: View {
    var attribute: Attribute
    
    private static let ICON_SIZE = 30.0
    
    var body: some View {
        Image(attribute
            .rawValue.lowercased()
        )
        .resizable()
        .frame(width: AttributeViewModel.ICON_SIZE, height: AttributeViewModel.ICON_SIZE)
        .cornerRadius(AttributeViewModel.ICON_SIZE)
    }
}

struct AttributeViewModel_Previews: PreviewProvider {
    static var previews: some View {
        AttributeViewModel(attribute: Attribute(rawValue: "Light")!)
            .previewDisplayName("Light")
        AttributeViewModel(attribute: Attribute(rawValue: "Dark")!)
            .previewDisplayName("Dark")
        AttributeViewModel(attribute: Attribute(rawValue: "Earth")!)
            .previewDisplayName("Earth")
        AttributeViewModel(attribute: Attribute(rawValue: "Wind")!)
            .previewDisplayName("Wind")
        AttributeViewModel(attribute: Attribute(rawValue: "Fire")!)
            .previewDisplayName("Fire")
        AttributeViewModel(attribute: Attribute(rawValue: "Water")!)
            .previewDisplayName("Water")
    }
}
