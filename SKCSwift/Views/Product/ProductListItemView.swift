//
//  ProductRowView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/23/24.
//

import SwiftUI

struct ProductListItemView: View {
    var product: Product
    
    var body: some View {
        HStack(alignment: .top) {
            RoundedRectImage(width: 50, height: 90,
                             imageUrl: URL(string: "https://images.thesupremekingscastle.com/products/x-sm/\(product.productId).png")!,
                             cornerRadius: 0)
            .padding(.trailing, 3)
            VStack(alignment: .leading) {
                InlineDateView(date: product.productReleaseDate)
                Text("\(product.productId)")
                    .frame(alignment: .trailing)
                    .font(.subheadline)
                    .fontWeight(.light)
                Text(product.productName)
                    .fontWeight(.bold)
                    .font(.subheadline)
                    .lineLimit(2)
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
                                         productType: "Pack", productSubType: "Core Set", productReleaseDate: "2024-02-09", productContent: []))
}
