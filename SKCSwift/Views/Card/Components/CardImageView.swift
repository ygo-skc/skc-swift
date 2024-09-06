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
    
    private let colorOverLayWidth: CGFloat
    private let radius: CGFloat
    
    private static let CARD_BACK_IMAGE = Image(.cardBackground)
    
    init(length: CGFloat, cardID: String, imgSize: ImageSize, cardColor: String? = nil, variant: YGOCardImageVariant = .round) {
        self.length = length
        self.variant = variant
        self.imgSize = imgSize
        self.cardID = cardID
        self.cardColor = cardColor
        
        self.colorOverLayWidth = length / 18
        self.radius = (variant == .round) ? length : length / 10
    }
    
    var body: some View {
        CachedAsyncImage(url: URL(string: "https://images.thesupremekingscastle.com/cards/\(imgSize.rawValue)/\(cardID).jpg")!) { phase in
            switch phase {
            case .empty:
                PlaceholderView(width: length, height: length, radius: radius)
            case .success(let image):
                image
                    .cardImageViewModifier(length: length, radius: radius, cardColor: cardColor, colorOverLayWidth: colorOverLayWidth)
            default:
                CardImageView.CARD_BACK_IMAGE
                    .cardImageViewModifier(length: length, radius: radius, cardColor: cardColor, colorOverLayWidth: colorOverLayWidth)
            }
        }
        .frame(width: length, height: length)
    }
}

private extension Image {
    func cardImageViewModifier(length: CGFloat, radius: CGFloat, cardColor: String?, colorOverLayWidth: CGFloat) -> some View {
        self
            .resizable()
            .aspectRatio(1.0, contentMode: .fit)
            .clipped()
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
    CardImageView(length: 240.0, cardID: "73146473", imgSize: .medium, variant: .roundedCorner)
}

#Preview("Rounded Corner - IMG DNE") {
    CardImageView(length: 240.0, cardID: "73146473", imgSize: .medium, variant: .roundedCorner)
}
