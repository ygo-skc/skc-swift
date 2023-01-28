//
//  RelatedProductsViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/27/23.
//

import SwiftUI

struct RelatedProductsViewModel: View {
    var cardName: String
    var products: [Product]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Products")
                .font(.title3)
                .fontWeight(.heavy)
            
            CardViewButton(text: "TCG", sheetContents: RelatedProductsContentViewModels(cardName: cardName, products: self.products))
                .disabled(products.isEmpty)
            HStack {
                Text(String(products.count))
                    .font(.body)
                    .fontWeight(.bold)
                Text("Printing(s)")
                    .font(.body)
                    .fontWeight(.light)
                    .padding(.leading, -5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct RelatedProductsViewModel_Previews: PreviewProvider {
    static var previews: some View {
        RelatedProductsViewModel(cardName: "Stratos", products: [
            Product(productId: "HAC1", productLocale: "EN", productName: "Hidden Arsenal: Chapter 1", productType: "Set", productSubType: "Collector", productReleaseDate: "2022-03-11",
                    productContent: [
                        ProductContent(productPosition: "015", rarities: ["Duel Terminal Normal Parallel Rare", "Common"])
                    ]
                   )
        ])
    }
}
