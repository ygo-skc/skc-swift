//
//  RectanglePlaceholderViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/3/23.
//

import SwiftUI

struct PlaceholderView: View {
    private let width: CGFloat
    private let height: CGFloat
    private let radius: CGFloat
    
    init(width: CGFloat = 300, height: CGFloat = 300, radius: CGFloat = 10) {
        self.width = width
        self.height = height
        self.radius = radius
    }
    
    var body: some View {
        Rectangle()
            .foregroundColor(.gray.opacity(0.70))
            .cornerRadius(radius)
            .frame(width: width, height: height)
    }
}

struct RectPlaceholderViewModel_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderView(width: UIScreen.main.bounds.width - 20)
    }
}
