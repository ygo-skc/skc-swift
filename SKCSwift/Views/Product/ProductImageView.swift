//
//  ProductImage.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/27/24.
//

import SwiftUI
import Kingfisher

struct ProductImageView: View, Equatable {
    private let height: CGFloat
    private let width: CGFloat
    private let productID: String
    private let imgSize: ImageSize

    @Environment(\.displayScale) private var displayScale

    private static let RATIO = 1.667

    static func == (lhs: ProductImageView, rhs: ProductImageView) -> Bool {
        lhs.width == rhs.width &&
        lhs.height == rhs.height &&
        lhs.productID == rhs.productID &&
        lhs.imgSize == rhs.imgSize
    }

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
        if productID.hasPrefix(Product.placeholderId) {
            PlaceholderView(width: width, height: height, radius: 0)
        } else {
            KFImage(URL(string: "https://images.thesupremekingscastle.com/products/\(imgSize.rawValue)/\(productID).png")!)
                .backgroundDecode()
                .downsampling(size: CGSize(width: width, height: height))
                .scaleFactor(displayScale)
                .cacheOriginalImage()
                .reducePriorityOnDisappear(true)
                .loadTransition(OpacityTransition(), animation: .easeOut(duration: 0.2))
                .placeholder {
                    PlaceholderView(width: width, height: height, radius: 0)
                }
                .onFailureView {
                    Image(.unknownProduct)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: width, height: height)
                }
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: height)
        }
    }
}

#Preview {
    ProductImageView(width: 50, productID: "INFO", imgSize: .tiny)
}

#Preview {
    ProductImageView(width: 50, productID: "INF", imgSize: .tiny)
}
