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
    @State private var releaseDate: String? = nil
    
    private func fetch() {
        if product == nil {
            request(url: productInfoURL(productID: productID), priority: 0.5) { (result: Result<Product, Error>) -> Void in
                switch result {
                case .success(let product):
                    let dateFormat = Dates.yyyyMMddGMT
                    let releaseDate = dateFormat.formatter.date(from: product.productReleaseDate)!
                    let (month, day, year) =  releaseDate.getMonthDayAndYear(calendar: dateFormat.calendar)
                    
                    DispatchQueue.main.async {
                        self.product = product
                        self.releaseDate = "\(month), \(day) \(year)"
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
                    .padding(.top)
                if let product {
                    if let releaseDate {
                        Text(releaseDate).fontWeight(.bold)
                    }
                    Text([productID, product.productType, product.productSubType].joined(separator: " | "))
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
