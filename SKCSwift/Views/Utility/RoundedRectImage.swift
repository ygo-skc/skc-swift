//
//  RoundedRectImage.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import SwiftUI
import Kingfisher

struct RoundedRectImage: View, Equatable {
    private let width: CGFloat
    private let height: CGFloat
    private let imageUrl: URL
    private let cornerRadius: CGFloat
    
    init(width: CGFloat, height: CGFloat, imageUrl: URL, cornerRadius: CGFloat? = nil) {
        self.width = width
        self.height = height
        self.imageUrl = imageUrl
        self.cornerRadius = cornerRadius ?? 50.0
    }
    
    var body: some View {
        KFImage(imageUrl)
            .backgroundDecode()
            .downsampling(size: CGSize(width: width, height: height))
            .scaleFactor(UIScreen.main.scale)
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
