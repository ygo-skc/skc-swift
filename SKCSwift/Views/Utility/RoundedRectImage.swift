//
//  RoundedRectImage.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import SwiftUI
import CachedAsyncImage

struct RoundedRectImage: View, Equatable {
    let width: CGFloat
    let height: CGFloat
    let imageUrl: URL
    var cornerRadius = 50.0
    
    var body: some View {
        CachedAsyncImage(url: imageUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
            switch phase {
            case .empty:
                PlaceholderView(width: width, height: height, radius: cornerRadius)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height)
                    .cornerRadius(cornerRadius)
            default:
                PlaceholderView(width: width, height: height, radius: cornerRadius)
            }
        }
        .frame(width: width, height: height)
    }
}

struct RoundedRectImage_Previews: PreviewProvider {
    static var previews: some View {
        let screenWidth = UIScreen.main.bounds.width - 20
        
        RoundedRectImage(width: screenWidth, height: screenWidth, imageUrl: URL(string: "https://images.thesupremekingscastle.com/cards/original/90307498.jpg")!)
            .previewDisplayName("Kluger")
        RoundedRectImage(width: screenWidth, height: screenWidth, imageUrl: URL(string: "https://images.thesupremekingscastle.com/cards/original/87468732.jpg")!)
            .previewDisplayName("Pendulum")
    }
}
