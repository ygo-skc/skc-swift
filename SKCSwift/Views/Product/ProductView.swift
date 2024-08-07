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
    
    private func fetch() {
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
                        .padding(.bottom)
                    
                    if let content = product.productContent {
                        ForEach(content) { c in
                            if let card = c.card {
                                LazyVStack {
                                    NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
                                        VStack {
                                            CardListItemView(card: card)
                                                .equatable()
                                            Divider()
                                        }
                                        .contentShape(Rectangle())
                                    })
                                    .buttonStyle(.plain)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .modifier(ParentViewModifier(alignment: .center))
            .onAppear {
                fetch()
            }
        }
    }
}

#Preview {
    ProductView(productID: "LEDE")
}
