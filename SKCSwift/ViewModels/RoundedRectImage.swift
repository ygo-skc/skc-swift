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
    
    var body: some View {
        AsyncImage(url: imageUrl) { image in
            image.resizable()
                .frame(width: width, height: height)
                .cornerRadius(50.0)
        } placeholder: {
            RectPlaceholderViewModel(width: .infinity, height: .infinity, radius: 50.0)
        }.frame(width: width, height: height)
    }
}

struct RoundedRectImage_Previews: PreviewProvider {
    static var previews: some View {
        let screenWidth = UIScreen.main.bounds.width - 20
        let imageUrl = URL(string: "https://images.thesupremekingscastle.com/cards/original/90307498.jpg")!
        
        RoundedRectImage(width: screenWidth, height: screenWidth, imageUrl: imageUrl)
    }
}
