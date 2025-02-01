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
    @State var model: ProductViewModel
    
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
                    ProductInfoView(productID: model.productID, product: model.product)
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

private struct ProductInfoView: View {
    let productID: String
    let product: Product?
    
    var body: some View {
        VStack{
            ProductImageView(width: 150, productID: productID, imgSize: .small)
                .padding(.vertical)
            if let product = product {
                InlineDateView(date: product.productReleaseDate)
                Text([product.productType, product.productSubType].joined(separator: " | "))
                    .font(.subheadline)
                
                if let contents = product.productContent {
                    ProductContentView(productID: productID, contents: contents)
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

private struct ProductContentView: View {
    let productID: String
    let contents: [ProductContent]
    
    var body: some View {
        LazyVStack {
            ForEach(contents) { content in
                if let card = content.card {
                    NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
                        GroupBox(label: Label("\(productID)-\(content.productPosition)", systemImage: "number.circle.fill").font(.subheadline)) {
                            CardListItemView(card: card, showAllInfo: true)
                                .equatable()
                            
                            FlowLayout(spacing: 6) {
                                ForEach(content.rarities, id: \.self) { rarity in
                                    Text(rarity.cardRarityShortHand())
                                        .modifier(TagModifier())
                                }
                            }
                        }
                        .groupBoxStyle(.listItem)
                    })
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ProductView(productID: "LEDE")
}
