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
                
                Text(product.productName)
                    .fontWeight(.bold)
                    .font(.subheadline)
                    .lineLimit(1)
                
                if let contents = product.productContent, !contents.isEmpty {
                    FlowLayout(spacing: 6) {
                        Text("Printed as:")
                            .font(.callout)
                        ForEach(contents[0].rarities, id: \.self) { rarity in
                            Text(rarity.cardRarityShortHand())
                                .modifier(TagModifier())
                        }
                    }
                } else {
                    FlowLayout(spacing: 6) {
                        Group {
                            Label(product.productId, systemImage: "number")
                            Label("\(product.productType)", systemImage: "tag")
                            Label("\(product.productSubType)", systemImage: "tag")
                            if let productTotal = product.productTotal {
                                Label("\(productTotal) card(s)", systemImage: "tray.full.fill")
                            }
                        }
                        .modifier(TagModifier())
                    }
                }
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ProductListItemView(product: Product(productId: "PHNI", productLocale: "EN", productName: "Phantom Nightmare",
                                         productType: "Pack", productSubType: "Core Set", productReleaseDate: "2024-02-09", productTotal: 100))
}
