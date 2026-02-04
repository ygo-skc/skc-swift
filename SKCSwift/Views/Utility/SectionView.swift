//
//  SwiftUIView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct SectionView<Content: View>: View {
    let header: String
    let content: Content
    
    init(header: String, @ViewBuilder content: () -> Content) {
        self.header = header
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(header)
                .modifier(.headerText)
            
            GroupBox {
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .groupBoxStyle(.sectionContent)
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
