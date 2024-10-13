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
            switch await data(Product.self, url: productInfoURL(productID: productID)) {
            case .success(let product):
                self.product = product
            case .failure(_): break
            }
        }
    }
    
    var body: some View {
        TabView {
            ScrollView {
                VStack{
                    ProductImageView(width: 150, productID: productID, imgSize: .small)
                        .padding(.vertical)
                    if let product {
                        InlineDateView(date: product.productReleaseDate)
                        Text([product.productType, product.productSubType].joined(separator: " | "))
                            .font(.subheadline)
                        
                        if let content = product.productContent {
                            LazyVStack {
                                ForEach(content) { c in
                                    if let card = c.card {
                                        NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
                                            GroupBox(label: Label("\(productID)-\(c.productPosition)", systemImage: "number.circle.fill").font(.subheadline)) {
                                                CardListItemView(card: card, showAllInfo: true)
                                                    .equatable()
                                            }
                                            .groupBoxStyle(.listItem)
                                        })
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    } else {
                        ProgressView("Loading...")
                            .controlSize(.large)
                    }
                }
                .modifier(ParentViewModifier(alignment: .center))
                .padding(.bottom, 40)
                .task(priority: .userInitiated) {
                    await fetch()
                }
            }
            
            ScrollView {
                ProductCardSuggestionsView(productID: productID, productName: product?.productName)
                    .modifier(ParentViewModifier(alignment: .center))
                    .padding(.bottom, 30)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

#Preview {
    ProductView(productID: "LEDE")
}
