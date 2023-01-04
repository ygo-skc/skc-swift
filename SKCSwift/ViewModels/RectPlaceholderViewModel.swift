//
//  RectanglePlaceholderViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/3/23.
//

import SwiftUI

struct RectPlaceholderViewModel: View {
    let width: CGFloat
    let height: CGFloat
    let radius: CGFloat
    
    var body: some View {
        Rectangle()
            .foregroundColor(.gray.opacity(0.70))
            .cornerRadius(radius).frame(width: width, height: height)
    }
}

struct RectPlaceholderViewModel_Previews: PreviewProvider {
    static var previews: some View {
        RectPlaceholderViewModel(width: UIScreen.main.bounds.width, height: 300, radius: 10)
    }
}
