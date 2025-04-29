//
//  ProductImage.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/27/24.
//

import SwiftUI
import CachedAsyncImage

struct ProductImageView: View, Equatable {
    private let height: CGFloat
    private let width: CGFloat
    private let productID: String
    private let imgSize: ImageSize
    
    private static let RATIO = 1.667
    
    init(height: CGFloat, productID: String, imgSize: ImageSize) {
        self.height = height
        self.width = height / ProductImageView.RATIO
        self.imgSize = imgSize
        self.productID = productID
    }
    
    init(width: CGFloat, productID: String, imgSize: ImageSize) {
        self.width = width
        self.height = width * ProductImageView.RATIO
        self.imgSize = imgSize
        self.productID = productID
    }
    
    var body: some View {
        CachedAsyncImage(url: URL(string: "https://images.thesupremekingscastle.com/products/\(imgSize.rawValue)/\(productID).png")!,
                         urlCache: URLCache.imageCache) { phase in
            switch phase {
            case .empty:
                PlaceholderView(width: width, height: height, radius: 0)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height)
            default:
                Image(.unknownProduct)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height)
            }
        }
        .frame(width: width, height: height)
    }
}

#Preview {
    ProductImageView(width: 50, productID: "INFO", imgSize: .tiny)
}

#Preview {
    ProductImageView(width: 50, productID: "INF", imgSize: .tiny)
}
