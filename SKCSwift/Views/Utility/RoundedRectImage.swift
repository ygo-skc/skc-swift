//
//  RoundedRectImage.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import SwiftUI
import Kingfisher

struct RoundedRectImage: View, Equatable {
    let width: CGFloat
    let height: CGFloat
    let imageUrl: URL
    var cornerRadius = 50.0
    
    var body: some View {
        KFImage(imageUrl)
            .backgroundDecode()
            .placeholder {
                PlaceholderView(width: width, height: height, radius: cornerRadius)
            }
            .onFailureView {
                PlaceholderView(width: width, height: height, radius: cornerRadius)
            }
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(cornerRadius)
            .frame(width: width, height: height)
    }
}

#Preview("Kluger") {
    GeometryReader { reader in
        let screenWidth = reader.size.width
        RoundedRectImage(width: screenWidth,
                         height: screenWidth,
                         imageUrl: URL(string: "https://images.thesupremekingscastle.com/cards/original/90307498.jpg")!)
    }
}

#Preview("Pend") {
    GeometryReader { reader in
        let screenWidth = reader.size.width
        RoundedRectImage(width: screenWidth,
                         height: screenWidth,
                         imageUrl: URL(string: "https://images.thesupremekingscastle.com/cards/original/87468732.jpg")!)
    }
}
