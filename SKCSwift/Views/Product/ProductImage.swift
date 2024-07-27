//
//  ProductImage.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/27/24.
//

import SwiftUI
import CachedAsyncImage

struct ProductImage: View, Equatable {
    private let height: CGFloat
    private let width: CGFloat
    private let productID: String
    private let imgSize: ImageSize
    
    private let imgUrl: URL
    private let fallbackUrl: URL
    
    private static let RATIO = 1.667
    
    init(height: CGFloat, productID: String, imgSize: ImageSize) {
        self.height = height
        self.width = height / ProductImage.RATIO
        self.imgSize = imgSize
        self.productID = productID
        
        self.imgUrl = URL(string: "https://images.thesupremekingscastle.com/products/tn/\(productID).png")!
        self.fallbackUrl = URL(string: "https://images.thesupremekingscastle.com/products/\(productID)/default-product-image.png")!
    }
    
    init(width: CGFloat, productID: String, imgSize: ImageSize) {
        self.width = width
        self.height = width * ProductImage.RATIO
        self.imgSize = imgSize
        self.productID = productID
        
        self.imgUrl = URL(string: "https://images.thesupremekingscastle.com/products/tn/\(productID).png")!
        self.fallbackUrl = URL(string: "https://images.thesupremekingscastle.com/products/\(imgSize.rawValue)/default-product-image.png")!
    }
    
    var body: some View {
        CachedAsyncImage(url: imgUrl, transaction: Transaction(animation: .easeInOut)) { phase in
            switch phase {
            case .empty:
                PlaceholderView(width: width, height: height, radius: 0)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height)
            default:
                CachedAsyncImage(url: fallbackUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: width, height: height)
                } placeholder: {
                    PlaceholderView(width: width, height: height, radius: 0)
                }
            }
        }
        .frame(width: width, height: height)
    }
}

#Preview {
    ProductImage(width: 50, productID: "INFO", imgSize: .tiny)
}

#Preview {
    ProductImage(width: 50, productID: "INF", imgSize: .tiny)
}
