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
    @ViewBuilder var destination: () -> Destination
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(header)
                .font(.title2)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .padding(.bottom, -1)
            
            if (disableDestination) {
                content()
                    .modifier(SectionViewModifier(variant: SectionViewVariant.gray))
            } else {
                NavigationLink(destination: destination, label: {
                    content()
                        .modifier(SectionViewModifier(variant: SectionViewVariant.gray))
                })
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

enum SectionViewVariant {
    case gray
}

private struct SectionViewModifier: ViewModifier {
    var variant: SectionViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .gray:
            content
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    alignment: .topLeading
                )
                .padding(.vertical)
                .padding(.horizontal)
                .background(Color("gray"))
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
