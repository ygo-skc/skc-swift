//
//  SwiftUIView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct SectionView<Destination: View, Content: View>: View {
    var header: String
    var disableDestination: Bool
    var variant: SectionViewVariant = .styled
    
    @ViewBuilder var destination: () -> Destination
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: (variant == .styled) ? 5 : 10) {
            Text(header)
                .font(.title2)
                .fontWeight(.heavy)
            if disableDestination {
                content()
                    .modifier(SectionContentViewModifier(variant: variant))
            } else {
                NavigationLink(destination: destination, label: {
                    content()
                        .modifier(SectionContentViewModifier(variant: variant))
                })
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
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

struct SectionView_Previews: PreviewProvider {
    static var previews: some View {
        SectionView(
            header: "Header",
            disableDestination: true,
            destination: {EmptyView()},
            content: {
                VStack {
                    Text("Yo")
                }}
        )
        .padding(.horizontal)
        .previewDisplayName("Styled")
        
        SectionView(
            header: "Header",
            disableDestination: true,
            variant: .plain,
            destination: {EmptyView()},
            content: {
                VStack {
                    Text("This is some text!")
                }}
        )
        .padding(.horizontal)
        .previewDisplayName("Plain")
    }
}
