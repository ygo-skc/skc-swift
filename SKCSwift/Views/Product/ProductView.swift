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
    
    var body: some View {
        ScrollView {
            VStack{
                ProductImage(width: 150, productID: productID, imgSize: .small)
                    .padding(.top)
                if let product {
                    Text(product.productId)
                    Text("\(product.productType) | \(product.productSubType)")
                    Text(product.productType)
                        .padding(.bottom)
                    
                    if let content = product.productContent {
                        ForEach(content) { c in
                            if let card = c.card {
                                LazyVStack {
                                    NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
                                        VStack {
                                            CardListItemView(cardID: card.cardID, cardName: card.cardName, monsterType: card.monsterType)
                                                .equatable()
                                            Divider()
                                        }
                                        .padding(.leading, 5)
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
                        .padding(.vertical)
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
