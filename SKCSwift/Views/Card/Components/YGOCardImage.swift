//
//  YGOCardImage.swift
//  SKCSwift
//
//  Created by Javi Gomez on 12/31/23.
//

import SwiftUI

struct YGOCardImage: View {
    var height: CGFloat
    var imgSize: ImageSize
    var cardID: String
    var variant: YGOCardImageVariant
    private var imgUrl: URL
    
    private let fallbackUrl: URL
    private let radius: CGFloat
    
    init(height: CGFloat, imgSize: ImageSize, cardID: String, variant: YGOCardImageVariant = .round) {
        self.height = height
        self.variant = variant
        self.imgSize = imgSize
        self.cardID = cardID
        self.imgUrl = URL(string: "https://images.thesupremekingscastle.com/cards/\(imgSize.rawValue)/\(cardID).jpg")!
        
        fallbackUrl = URL(string: "https://images.thesupremekingscastle.com/cards/\(imgSize.rawValue)/default-card-image.jpg")!
        
        if variant == .round {
            self.radius = height
        } else {
            self.radius = height / 10
        }
    }
    
    var body: some View {
        AsyncImage(url: imgUrl, transaction: Transaction(animation: .easeInOut)) { phase in
            switch phase {
            case .empty:
                PlaceholderView(width: height, height: height, radius: radius)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: height, height: height)
                    .cornerRadius(radius)
            default:
                AsyncImage(url: fallbackUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: height, height: height)
                        .cornerRadius(radius)
                } placeholder: {
                    PlaceholderView(width: height, height: height, radius: radius)
                }
            }
        }
        .frame(width: height, height: height)
    }
}

#Preview("Rounded") {
    YGOCardImage(height: 60.0, imgSize: .tiny, cardID: "73146473", variant: .round)
}

#Preview("Rounded Corner") {
    YGOCardImage(height: 240.0, imgSize: .medium, cardID: "73146473", variant: .rounded_corner)
}

#Preview("Rounded Corner - IMG DNE") {
    YGOCardImage(height: 240.0, imgSize: .medium, cardID: "73146474", variant: .rounded_corner)
}
