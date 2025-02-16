//
//  TabButton.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/1/23.
//

import SwiftUI

struct TabButton<T: RawRepresentable>: View where T.RawValue == String {
    @Binding var selected: T    // current selected value
    var value: T   // current tab button value
    var animmation: Namespace.ID
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2)) {selected = value}
        })
        {
            Text(value.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(selected == value ? .white : .primary)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .if(selected == value) {
                    $0.background {
                        Color.accentColor
                            .clipShape(Capsule())
                            .matchedGeometryEffect(id: "Tab", in: animmation)
                    }
                } else: {
                    $0.background {
                        Color.gray.opacity(0.3)
                            .clipShape(Capsule())
                    }
                }
        }
    }
}

struct TabButton_Previews: PreviewProvider {
    static var previews: some View {
        @State var format: BanListFormat = .tcg
        @Namespace var animation
        
        HStack {
            TabButton(selected: $format, value: .tcg, animmation: animation)
            TabButton(selected: $format, value: .md, animmation: animation)
        }
    }
}
