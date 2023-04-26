//
//  RoundedRectImage.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import SwiftUI

struct RoundedRectImage: View {
    var width: CGFloat
    var height: CGFloat
    var imageUrl: URL
    var cornerRadius = 50.0
    
    var body: some View {
        AsyncImage(url: imageUrl) { image in
            image
                .resizable()
                .frame(width: width, height: height)
                .cornerRadius(cornerRadius)
        } placeholder: {
            RectPlaceholderView(width: width, height: width, radius: 50.0)
        }.frame(width: width, height: height)
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

