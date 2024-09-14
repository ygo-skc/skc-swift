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
                Task { @MainActor in
                    self.product = product
                }
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
                .padding(.bottom, 40)
                .modifier(ParentViewModifier(alignment: .topLeading))
                .task(priority: .userInitiated) {
                    await fetch()
                }
            }
            
            ScrollView {
                VStack {
                    if let product {
                        ProductCardSuggestionsView(productID: productID, productName: product.productName)
                    } else {
                        ProgressView("Loading...")
                            .controlSize(.large)
                    }
                }
                .padding(.bottom, 30)
                .modifier(ParentViewModifier(alignment: .topLeading))
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

#Preview {
    ProductView(productID: "LEDE")
}
