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
        VStack(alignment: .leading, spacing: 5) {
            Text(header)
                .font(.title2)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
            
            if (disableDestination) {
                content()
                    .modifier(SectionViewModifier(variant: variant))
            } else {
                NavigationLink(destination: destination, label: {
                    content()
                        .modifier(SectionViewModifier(variant: variant))
                })
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

private struct SectionViewModifier: ViewModifier {
    var variant: SectionViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .plain:
            content
        case .styled:
            content
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
    }
}
