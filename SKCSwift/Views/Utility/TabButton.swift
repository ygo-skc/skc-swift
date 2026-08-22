//
//  TabButton.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/1/23.
//

import SwiftUI

struct TabButton<T: RawRepresentable>: View where T.RawValue == String {
    @Binding var selected: T
    let value: T
    let animation: Namespace.ID
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.15)) {selected = value}
        }) {
            Text(value.rawValue)
                .font(TagConstants.FONT)
                .fontWeight(.medium)
                .lineLimit(1)
                .foregroundStyle(selected == value ? Color.white : .primary)
                .padding(.horizontal, TagConstants.HORIZONTAL_PADDING)
                .padding(.vertical, 6)  // deliberately > TagConstants.VERTICAL_PADDING - this is a touch target
                .background {
                    if selected == value {
                        Capsule()
                            .fill(Color.accentColor)
                            .matchedGeometryEffect(id: "Tab", in: animation)
                    } else {
                        Capsule()
                            .fill(TagConstants.NEUTRAL_WASH)
                    }
                }
        }
    }
}

struct TabButton_Previews: PreviewProvider {
    static var previews: some View {
        @State var format: CardRestrictionFormat = .tcg
        @Namespace var animation
        
        HStack {
            TabButton(selected: $format, value: .tcg, animation: animation)
            TabButton(selected: $format, value: .md, animation: animation)
        }
    }
}
