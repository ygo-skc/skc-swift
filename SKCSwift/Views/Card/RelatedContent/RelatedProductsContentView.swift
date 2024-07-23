//
//  RelatedProductsContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/24/23.
//

import SwiftUI

struct RelatedProductsContentView: RelatedContent {
    var cardName: String
    var products: [Product]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Products: \(products.count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .padding(.top)
                    Text("\(cardName) Was Printed In")
                        .font(.headline)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                })
            }
            .padding(.horizontal)
            
            List {
                ForEach(products, id: \.productId) { product in
                    ProductListItemView(product: product)
                }
            }
            .listStyle(.plain)
            .padding(.top, 0)
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

#Preview() {
    RelatedProductsContentView(cardName: "Elemental Hero Stratos", products: [
        Product(productId: "HAC1", productLocale: "EN", productName: "Hidden Arsenal: Chapter 1", productType: "Set", productSubType: "Collector",
                productReleaseDate: "2022-03-11", productContent: [
                    ProductContent(productPosition: "015", rarities: ["Duel Terminal Normal Parallel Rare", "Common"])
                ]),
        Product(productId: "BODE", productLocale: "EN", productName: "Burst of Destiny", productType: "Pack", productSubType: "Core Set",
                productReleaseDate: "2021-11-05", productContent: [
                    ProductContent(productPosition: "100", rarities: ["Starlight Rare"])
                ]),
        Product(productId: "MAGO", productLocale: "EN", productName: "Maximum Gold", productType: "Set", productSubType: "Gold Series",
                productReleaseDate: "2020-11-13", productContent: [
                    ProductContent(productPosition: "004", rarities: ["Premium Gold Rare"])
                ]),
        Product(productId: "BLHR", productLocale: "EN", productName: "Battles of Legend: Hero's Revenge", productType: "Pack", productSubType: "Battle of Legends",
                productReleaseDate: "2019-07-12", productContent: [
                    ProductContent(productPosition: "061", rarities: ["Ultra Rare"])
                ])
    ])
}
