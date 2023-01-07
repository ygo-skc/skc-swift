//
//  ExploreRelatedContentViewModels.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/7/23.
//

import SwiftUI

struct RelatedProductsContentViewModels: View {
    var cardName: String
    var products: [Product]
    
    var body: some View {
        if (products.isEmpty) {
            VStack {
                Text("No Products Found")
                    .font(.title)
                    .padding(.horizontal)
                Text("\(cardName) has not been released in the TCG or the DB does not have info on the products it was featured in")
                    .multilineTextAlignment(.center)
                    .padding(.top, 1)
                    .padding(.horizontal)
            }
        } else {
            NavigationStack {
                VStack(alignment: .leading) {
                    
                    Text("\(cardName) Was Printed In")
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .padding()
                    List {
                        ForEach(products, id: \.productId) { product in
                            ProductListItemViewModel(product: product)
                        }
                    }.listStyle(.plain)
                }
                .navigationTitle("Products")
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
            }
        }
    }
}

struct ProductListItemViewModel: View {
    var product: Product
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(product.productId)-\(product.productLocale)\(product.productContent[0].productPosition)")
                    .frame(alignment: .trailing)
                    .font(.subheadline)
                    .fontWeight(.thin)
                Text(product.productName)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.subheadline)
                    .fontWeight(.heavy)
                HStack {
                    Text("Rarities")
                        .font(.footnote)
                        .fontWeight(.bold)
                    Text(product.productContent[0].rarities.joined(separator: ", "))
                        .font(.callout)
                        .fontWeight(.thin)
                }
                .padding(.top, 1)
            }
            DateViewModel(date: product.productReleaseDate)
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
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
