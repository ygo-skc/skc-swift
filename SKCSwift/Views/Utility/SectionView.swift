//
//  SwiftUIView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct SectionView<Content:View>: View {
    var header: String
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(header)
                .font(.title2)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .padding(.bottom, -1)
            
            content()
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
        SectionView(header: "Test") {
            VStack {
                Text("Yo")
            }
        }
    }
}
