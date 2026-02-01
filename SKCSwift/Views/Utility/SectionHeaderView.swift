//
//  HeaderView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/25/24.
//

import SwiftUI

struct SectionHeaderView: View {
    let header: String
    
    var body: some View {
        HStack {
            Text(header)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.all, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .modify {
            if #available(iOS 26.0, *) {
                $0.glassEffect(.regular.tint(.orange), in: Rectangle())
            } else {
                $0.background(.ultraThinMaterial).background(.orange)
            }
        }
        .cornerRadius(8)
    }
}

#Preview {
    SectionHeaderView(header: "Header")
}
