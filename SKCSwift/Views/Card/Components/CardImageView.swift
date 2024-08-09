//
//  YGOCardImage.swift
//  SKCSwift
//
//  Created by Javi Gomez on 12/31/23.
//

import SwiftUI
import CachedAsyncImage

struct CardImageView: View, Equatable {
    private let length: CGFloat
    private let cardID: String
    private let imgSize: ImageSize
    private let variant: YGOCardImageVariant
    private let cardColor: String?
    private let imgUrl: URL
    
    private let fallbackUrl: URL
    private let colorOverLayWidth: CGFloat
    private let radius: CGFloat
    
    init(length: CGFloat, cardID: String, imgSize: ImageSize, cardColor: String?, variant: YGOCardImageVariant = .round) {
        self.length = length
        self.variant = variant
        self.imgSize = imgSize
        self.cardID = cardID
        self.cardColor = cardColor
        self.imgUrl = URL(string: "https://images.thesupremekingscastle.com/cards/\(imgSize.rawValue)/\(cardID).jpg")!
        
        self.fallbackUrl = URL(string: "https://images.thesupremekingscastle.com/cards/\(imgSize.rawValue)/default-card-image.jpg")!
        self.colorOverLayWidth = length / 18
        self.radius = (variant == .round) ? length : length / 10
    }
    
    var body: some View {
        CachedAsyncImage(url: imgUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
            switch phase {
            case .empty:
                PlaceholderView(width: length, height: length, radius: radius)
            case .success(let image):
                image
                    .cardImageViewModifier(length: length, radius: radius, cardColor: cardColor, colorOverLayWidth: colorOverLayWidth)
            default:
                CachedAsyncImage(url: fallbackUrl) { image in
                    image
                        .cardImageViewModifier(length: length, radius: radius, cardColor: cardColor, colorOverLayWidth: colorOverLayWidth)
                } placeholder: {
                    PlaceholderView(width: length, height: length, radius: radius)
                }
            }
        }
        .frame(width: length, height: length)
    }
}

extension CardImageView {
    init(length: CGFloat, cardID: String, imgSize: ImageSize, variant: YGOCardImageVariant = .round) {
        self.init(length: length, cardID: cardID, imgSize: imgSize, cardColor: nil, variant: variant)
    }
}

private extension Image {
    func cardImageViewModifier(length: CGFloat, radius: CGFloat, cardColor: String?, colorOverLayWidth: CGFloat) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: length, height: length)
            .cornerRadius(radius)
            .if(cardColor != nil) { view in
                view.overlay(
                    Circle()
                        .if(cardColor!.starts(with: "Pendulum")) {
                            $0.stroke(cardColorGradient(cardColor: cardColor!), lineWidth: colorOverLayWidth)
                        } else: {
                            $0.stroke(cardColorUI(cardColor: cardColor!), lineWidth: colorOverLayWidth)
                        })
            }
    }
}

#Preview("Rounded") {
    CardImageView(length: 60.0, cardID: "73146473", imgSize: .tiny, variant: .round)
}

#Preview("Rounded Corner") {
    CardImageView(length: 240.0, cardID: "73146473", imgSize: .medium, variant: .rounded_corner)
}

#Preview("Rounded Corner - IMG DNE") {
    CardImageView(length: 240.0, cardID: "73146473", imgSize: .medium, variant: .rounded_corner)
}
