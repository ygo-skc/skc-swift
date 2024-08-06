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
        request(url: productInfoURL(productID: productID), priority: 0.2) { (result: Result<Product, Error>) -> Void in
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
                if let product {
                    HStack {
                        ProductImage(width: 100, productID: product.productId, imgSize: .small)
                            .padding(.trailing, 5)
                        SectionView(header: "Product Info",
                                    variant: .styled,
                                    content: {
                            VStack(alignment: .leading) {
                                Text(product.productId)
                                Text(product.productType)
                                Text(product.productSubType)
                                Text(product.productType)
                                if let total = product.productTotal {
                                    Text(String(total))
                                }
                            }
                        })
                    }
                    .frame(alignment: .topLeading)
                    
                    if let content = product.productContent {
                        ForEach(content, id: \.card?.cardID) { c in
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
                            }
                        }
                    }
                }
            }
            .modifier(ParentViewModifier())
            .onAppear {
                fetch()
            }
        }
    }
}

#Preview {
    ProductView(productID: "LEDE")
}
