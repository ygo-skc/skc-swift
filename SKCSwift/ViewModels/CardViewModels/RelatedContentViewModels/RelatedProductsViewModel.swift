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
    
    private var latestReleaseInfo: String
    
    init(cardName: String, products: [Product]) {
        self.cardName = cardName
        self.products = products
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if (!products.isEmpty) {
            let mostRecentProductReleaseDate = dateFormatter.date(from: products[0].productReleaseDate)!
            let elapsedInterval = mostRecentProductReleaseDate.timeIntervalSinceNow
            let elapsedDays = Int(floor(abs(elapsedInterval) / 60 / 60 / 24))
            
            if (elapsedInterval > 0) {
                latestReleaseInfo = "\(elapsedDays) day(s) until next printing"
            } else {
                latestReleaseInfo = "\(elapsedDays) day(s) since last printing"
            }
        } else {
            latestReleaseInfo = "Nothhing in DB"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Products")
                .font(.title2)
                .fontWeight(.black)
            
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
            
            HStack {
                Image(systemName: "calendar")
                Text(latestReleaseInfo)
                    .font(.subheadline)
                    .fontWeight(.light)
                    .padding(.top, 1)
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
