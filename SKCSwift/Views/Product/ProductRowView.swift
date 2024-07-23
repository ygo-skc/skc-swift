//
//  ProductRowView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/23/24.
//

import SwiftUI

struct ProductRowView: View {
    var product: Product
    
    var body: some View {
        HStack(alignment: .top) {
            RoundedRectImage(width: 40, height: 80, 
                             imageUrl: URL(string: "https://images.thesupremekingscastle.com/products/tn/\(product.productId).png")!, cornerRadius: 0)
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
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ProductRowView(product: Product(productId: "PHNI", productLocale: "EN", productName: "Phantom Nightmare",
                                    productType: "Pack", productSubType: "Core Set", productReleaseDate: "2024-02-09", productContent: []))
}
