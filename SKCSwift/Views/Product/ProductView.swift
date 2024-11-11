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
    private let model: ProductViewModel
    
    init(productID: String) {
        self.model = .init(productID: productID)
    }
    
    var body: some View {
        TabView {
            ScrollView {
                if let networkError = model.requestErrors[.product, default: nil] {
                    NetworkErrorView(error: networkError, action: { Task{ await model.fetchProductData(forceRefresh: true)} })
                        .padding(.top, 20)
                } else {
                    VStack{
                        ProductImageView(width: 150, productID: model.productID, imgSize: .small)
                            .padding(.vertical)
                        if let product = model.product {
                            InlineDateView(date: product.productReleaseDate)
                            Text([product.productType, product.productSubType].joined(separator: " | "))
                                .font(.subheadline)
                            
                            if let content = product.productContent {
                                LazyVStack {
                                    ForEach(content) { c in
                                        if let card = c.card {
                                            NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
                                                GroupBox(label: Label("\(model.productID)-\(c.productPosition)", systemImage: "number.circle.fill").font(.subheadline)) {
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
                }
            }
            .scrollDisabled(model.requestErrors[.product, default: nil] != nil)
            .task(priority: .userInitiated) {
                await model.fetchProductData()
            }
            
            ScrollView {
                ProductCardSuggestionsView(model: model)
                    .modifier(ParentViewModifier(alignment: .center))
                    .padding(.bottom, 30)
            }
            .scrollDisabled(model.requestErrors[.suggestions, default: nil] != nil)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

#Preview {
    ProductView(productID: "LEDE")
}
