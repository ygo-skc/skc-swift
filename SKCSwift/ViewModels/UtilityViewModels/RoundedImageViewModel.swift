//
//  RoundedImageViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct RoundedImageViewModel: View {
    var radius: CGFloat
    var imageUrl: URL
    
    var body: some View {
        AsyncImage(url: imageUrl) { image in
            image
                .resizable()
                .frame(width: radius, height: radius)
                .cornerRadius(radius)
        } placeholder: {
            RectPlaceholderViewModel(width: radius, height: radius, radius: radius)
        }
        .frame(width: radius, height: radius)
    }
}

struct RoundedImageViewModel_Previews: PreviewProvider {
    static var previews: some View {
        let radius = 250.0
        
        RoundedImageViewModel(radius: radius, imageUrl: URL(string: "https://images.thesupremekingscastle.com/cards/sm/90307498.jpg")!)
            .previewDisplayName("Kluger")
        RoundedImageViewModel(radius: radius, imageUrl: URL(string: "https://images.thesupremekingscastle.com/cards/sm/87468732.jpg")!)
            .previewDisplayName("Pendulum")
    }
}
