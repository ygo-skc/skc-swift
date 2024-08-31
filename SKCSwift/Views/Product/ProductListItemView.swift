//
//  ProductRowView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/23/24.
//

import SwiftUI

struct ProductListItemView: View, Equatable {
    let product: Product
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            ProductImageView(width: 55, productID: product.productId, imgSize: .tiny)
                .equatable()
                .padding(.trailing, 3)
            VStack(alignment: .leading) {
                InlineDateView(date: product.productReleaseDate)
                    .equatable()
                    .padding(.bottom, 2)
                Text(product.productIDWithContentTotal())
                    .frame(alignment: .trailing)
                    .font(.subheadline)
                    .fontWeight(.light)
                Text(product.productName)
                    .fontWeight(.bold)
                    .font(.headline)
                    .lineLimit(1)
                    .padding(.bottom, 0)
                Text(product.productCategory())
                    .frame(alignment: .trailing)
                    .font(.subheadline)
                
                if let contents = product.productContent, !contents.isEmpty {
                    HStack(alignment: .top) {
                        Text("Rarities")
                            .font(.callout)
                            .fontWeight(.medium)
                        Text(contents[0].rarities.joined(separator: ", "))
                            .font(.callout)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ProductListItemView(product: Product(productId: "PHNI", productLocale: "EN", productName: "Phantom Nightmare",
                                         productType: "Pack", productSubType: "Core Set", productReleaseDate: "2024-02-09", productTotal: 100))
}
