//
//  ProductRowView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/23/24.
//

import SwiftUI

struct ProductListView<Label: View>: View, Equatable {
    static func == (lhs: ProductListView, rhs: ProductListView) -> Bool {
        lhs.products == rhs.products
    }

    let products: [Product]
    let label: (Int) -> Label

    init(products: [Product],
         @ViewBuilder label: @escaping (Int) -> Label = { _ in EmptyView() }) {
        self.products = products
        self.label = label
    }

    var body: some View {
        LazyVStack {
            ForEach(Array(products.enumerated()), id: \.element.id) { ind, product in
                NavigationLink(value: ProductLinkDestinationValue(productID: product.productId,
                                                                 productName: product.productName)) {
                    GroupBox(label: label(ind)) {
                        ProductListItemView(product: product)
                            .equatable()
                    }
                    .groupBoxStyle(.listItem)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
        }
    }
}

struct ProductListItemView: View, Equatable {
    let product: Product
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            ProductImageView(width: 55, productID: product.productId, imgSize: .tiny)
                .equatable()
                .padding(.trailing, 3)
            VStack(alignment: .leading) {
                InlineDateView(date: product.productReleaseDate)
                    .equatable()
                    .padding(.bottom, 2)
                
                Text(product.productName)
                    .fontWeight(.bold)
                    .font(.subheadline)
                    .lineLimit(1)
                
                if let contents = product.productContent, !contents.isEmpty {
                    FlowLayout(spacing: 6) {
                        ForEach(contents[0].rarities, id: \.self) { rarity in
                            Text(rarity.cardRarityShortHand())
                                .modifier(TagModifier())
                        }
                    }
                } else {
                    FlowLayout(spacing: 6) {
                        Group {
                            Label(product.productId, systemImage: "number")
                            Label("\(product.productType)", systemImage: "tag")
                            Label("\(product.productSubType)", systemImage: "tag")
                            if let productTotal = product.productTotal {
                                Label("\(productTotal) card(s)", systemImage: "tray.full.fill")
                            }
                        }
                        .modifier(TagModifier())
                    }
                }
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ProductListItemView(product: Product(productId: "PHNI", productLocale: "EN", productName: "Phantom Nightmare",
                                         productType: "Pack", productSubType: "Core Set", productReleaseDate: Date.yyyyMMddLocal.formatter.date(from: "2024-02-09") ?? .distantPast, productTotal: 100))
}
