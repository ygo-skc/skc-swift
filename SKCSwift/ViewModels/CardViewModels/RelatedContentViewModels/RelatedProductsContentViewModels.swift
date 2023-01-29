//
//  RelatedProductsContentViewModels.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/24/23.
//

import SwiftUI

struct RelatedProductsContentViewModels: RelatedContent {
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
                        .fontWeight(.light)
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
            
            Divider()
            
            List {
                ForEach(products, id: \.productId) { product in
                    LazyVStack {
                        ProductListItemViewModel(product: product)
                    }
                }
            }.listStyle(.plain)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

private struct ProductListItemViewModel: View {
    var product: Product
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(product.productName)
                    .lineLimit(2)
                    .font(.subheadline)
                    .fontWeight(.heavy)
                Text("\(product.productId)-\(product.productLocale)\(product.productContent[0].productPosition)")
                    .frame(alignment: .trailing)
                    .font(.subheadline)
                    .fontWeight(.light)
                HStack {
                    Text("Rarities")
                        .font(.footnote)
                        .fontWeight(.bold)
                    Text(product.productContent[0].rarities.joined(separator: ", "))
                        .font(.callout)
                }
                .padding(.top, 1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            DateViewModel(date: product.productReleaseDate)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

struct RelatedProductsContentViewModels_Previews: PreviewProvider {
    static var previews: some View {
        let products = [
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
        ]
        
        RelatedProductsContentViewModels(cardName: "Elemental Hero Stratos", products: products)
        ProductListItemViewModel(product: products[0])
            .padding(.horizontal)
    }
}
