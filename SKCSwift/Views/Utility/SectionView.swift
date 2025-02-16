//
//  SwiftUIView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct SectionView<Content: View>: View {
    let header: String
    var variant: SectionViewVariant = .styled
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: (variant == .styled) ? 5 : 10) {
            Text(header)
                .font(.title2)
                .fontWeight(.black)
            
            switch variant {
            case .plain:
                content()
                    .modifier(SectionContentViewModifier(variant: variant))
            case .styled:
                GroupBox {
                    content()
                        .modifier(SectionContentViewModifier(variant: variant))
                }
                .groupBoxStyle(.sectionContent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private struct SectionContentViewModifier: ViewModifier {
    let variant: SectionViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .plain, .styled:
            content
                .frame(maxWidth: .infinity, alignment: .leading)
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
