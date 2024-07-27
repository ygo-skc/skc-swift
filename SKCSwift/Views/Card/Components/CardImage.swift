//
//  YGOCardImage.swift
//  SKCSwift
//
//  Created by Javi Gomez on 12/31/23.
//

import SwiftUI
import CachedAsyncImage

struct CardImage: View, Equatable {
    private let length: CGFloat
    private let imgSize: ImageSize
    private let cardID: String
    private let variant: YGOCardImageVariant
    private var imgUrl: URL
    
    private let fallbackUrl: URL
    private let radius: CGFloat
    
    init(length: CGFloat, cardID: String, imgSize: ImageSize, variant: YGOCardImageVariant = .round) {
        self.length = length
        self.variant = variant
        self.imgSize = imgSize
        self.cardID = cardID
        self.imgUrl = URL(string: "https://images.thesupremekingscastle.com/cards/\(imgSize.rawValue)/\(cardID).jpg")!
        
        self.fallbackUrl = URL(string: "https://images.thesupremekingscastle.com/cards/\(imgSize.rawValue)/default-card-image.jpg")!
        
        if variant == .round {
            self.radius = length
        } else {
            self.radius = length / 10
        }
    }
    
    var body: some View {
        CachedAsyncImage(url: imgUrl, transaction: Transaction(animation: .easeInOut)) { phase in
            switch phase {
            case .empty:
                PlaceholderView(width: length, height: length, radius: radius)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: length, height: length)
                    .cornerRadius(radius)
            default:
                CachedAsyncImage(url: fallbackUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: length, height: length)
                        .cornerRadius(radius)
                } placeholder: {
                    PlaceholderView(width: length, height: length, radius: radius)
                }
            }
        }
        .frame(width: length, height: length)
    }
}

#Preview("Rounded") {
    CardImage(length: 60.0, cardID: "73146473", imgSize: .tiny, variant: .round)
}

#Preview("Rounded Corner") {
    CardImage(length: 240.0, cardID: "73146473", imgSize: .medium, variant: .rounded_corner)
}

#Preview("Rounded Corner - IMG DNE") {
    CardImage(length: 240.0, cardID: "73146473", imgSize: .medium, variant: .rounded_corner)
}
