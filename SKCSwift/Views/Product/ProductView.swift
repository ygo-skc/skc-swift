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
    @State private var suggestions: ProductSuggestions? = nil
    
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
            
            request(url: productSuggestionsURL(productID: productID), priority: 0.5) { (result: Result<ProductSuggestions, Error>) -> Void in
                switch result {
                case .success(let suggestions):
                    DispatchQueue.main.async {
                        self.suggestions = suggestions
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    var body: some View {
        TabView {
            ScrollView {
                VStack{
                    ProductImage(width: 150, productID: productID, imgSize: .small)
                        .padding(.vertical)
                    if let product {
                        InlineDateView(date: product.productReleaseDate)
                        Text([product.productType, product.productSubType].joined(separator: " | "))
                            .font(.subheadline)
                    } else {
                        ProgressView()
                    }
                    
                    LazyVStack {
                        if let content = product?.productContent {
                            ForEach(content) { c in
                                if let card = c.card {
                                    NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
                                        GroupBox(label: Label("\(productID)-\(c.productPosition)", systemImage: "number.circle.fill").font(.subheadline)) {
                                            VStack {
                                                CardListItemView(card: card, showAllInfo: true)
                                                    .equatable()
                                            }
                                        }
                                        .groupBoxStyle(.list_item)
                                    })
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 40)
                .modifier(ParentViewModifier(alignment: .topLeading))
                .task(priority: .userInitiated) {
                    await fetch()
                }
            }
            
            ScrollView {
                VStack(alignment: .leading) {
                    if let suggestions {
                        SuggestionCarouselView(header: "Named Materials", subHeader: "Cards that can be used as summoning material",
                                               references: suggestions.suggestions.namedMaterials)
                        SuggestionCarouselView(header: "Named References", subHeader: "Cards found in card text - non materials",
                                               references: suggestions.suggestions.namedReferences)
                        SupportCarouselView(header: "Material For", subHeader: "Cards that can be summoned using this card as material",
                                            references: suggestions.support.materialFor)
                        SupportCarouselView(header: "Referenced By", subHeader: "Cards that reference this card - excludes ED cards that reference this card as a summoning material",
                                            references: suggestions.support.referencedBy)
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
