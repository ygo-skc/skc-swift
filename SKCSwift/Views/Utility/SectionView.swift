//
//  SwiftUIView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct SectionView<Content: View>: View {
    var header: String
    var variant: SectionViewVariant = .styled
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: (variant == .styled) ? 5 : 10) {
            Text(header)
                .font(.title2)
                .fontWeight(.bold)
            content()
                .modifier(SectionContentViewModifier(variant: variant))
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private struct SectionContentViewModifier: ViewModifier {
    var variant: SectionViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .plain:
            content
                .frame(maxWidth: .infinity, alignment: .leading)
        case .styled:
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical)
                .padding(.horizontal)
                .background(Color("section-background"))
                .cornerRadius(15)
        }
    }
}

#Preview("Styled") {
    SectionView(
        header: "Header",
        content: {
            VStack {
                Text("Yo")
            }}
    )
    .padding(.horizontal)
}

#Preview("Plain") {
    SectionView(
        header: "Header",
        variant: .plain,
        content: {
            VStack {
                Text("This is some text!")
            }}
    )
    .padding(.horizontal)
}
