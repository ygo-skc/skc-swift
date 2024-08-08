//
//  ProductView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/5/24.
//

import SwiftUI

struct ProductLinkDestinationView: View {
    let productLinkDestinationValue: ProductLinkDestinationValue
    
    var body: some View {
        ProductView(productID: productLinkDestinationValue.productID)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(productLinkDestinationValue.productName)
    }
}

struct ProductView: View {
    let productID: String
    
    @State private var product: Product? = nil
    
    private func fetch() async {
        if product == nil {
            request(url: productInfoURL(productID: productID), priority: 0.5) { (result: Result<Product, Error>) -> Void in
                switch result {
                case .success(let product):
                    DispatchQueue.main.async {
                        self.product = product
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack{
                ProductImage(width: 150, productID: productID, imgSize: .small)
                    .padding(.vertical)
                if let product {
                    InlineDateView(date: product.productReleaseDate)
                    Text([productID, product.productType, product.productSubType].joined(separator: " | "))
                        .font(.subheadline)
                    
                    if let content = product.productContent {
                        LazyVStack {
                            ForEach(content) { c in
                                if let card = c.card {
                                    NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
                                        GroupBox(label: Label("\(productID) | \(c.productPosition)", systemImage: "number.circle.fill").font(.subheadline)) {
                                            VStack {
                                                CardListItemView(card: card, showEffect: true)
                                                    .equatable()
                                            }
                                        }
                                        .contentShape(Rectangle())
                                    })
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    ProgressView()
                }
            }
            .modifier(ParentViewModifier(alignment: .center))
            .task(priority: .userInitiated) {
                await fetch()
            }
        }
    }
}

#Preview {
    ProductView(productID: "LEDE")
}
