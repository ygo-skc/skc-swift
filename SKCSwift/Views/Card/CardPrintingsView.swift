//
//  CardPrintingsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/8/26.
//

import SwiftUI

struct CardPrintingsView: View {
    let cardName: String
    let products: [Product]

    init(values: CardPrintingsLinkDestinationValue) {
        self.cardName = values.cardName
        self.products = values.products
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                Text("**\(cardName)** was printed in \(products.count) different products.")
                    .font(.callout)

                ProductListView(products: products)
                    .equatable()
            }
            .parentModifier()
        }
        .navigationTitle("Printings")
        .navigationBarTitleDisplayMode(.large)
    }
}
