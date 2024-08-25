//
//  HeaderView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/25/24.
//

import SwiftUI

struct HeaderView: View {
    let header: String
    
    var body: some View {
        HStack {
            Text(header)
                .font(.headline)
                .fontWeight(.black)
            Spacer()
        }
        .padding(.all, 5)
        .background(.thinMaterial)
        .cornerRadius(5)
    }
}

#Preview {
    HeaderView(header: "Header")
}
