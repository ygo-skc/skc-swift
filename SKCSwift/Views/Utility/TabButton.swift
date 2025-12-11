//
//  TabButton.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/1/23.
//

import SwiftUI

struct TabButton<T: RawRepresentable>: View where T.RawValue == String {
    @Binding var selected: T
    var value: T
    var animation: Namespace.ID
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2)) {selected = value}
        })
        {
            Text(value.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(selected == value ? .white : .primary)
                .padding(.vertical, 7)
                .padding(.horizontal, 10)
                .if(selected == value) {
                    $0.background {
                        Color.accentColor
                            .matchedGeometryEffect(id: "Tab", in: animation)
                    }
                } else: {
                    $0.background {
                        Color.gray.opacity(0.3)
                    }
                }
                .cornerRadius(7)
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
