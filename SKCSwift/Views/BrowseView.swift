//
//  BrowseView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/11/24.
//

import SwiftUI

struct BrowseView: View {
    @State var productsByYear: [String: [Product]]?
    
    private func fetch() async {
        if productsByYear == nil {
            request(url: productsURL(), priority: 0.4) { (result: Result<Products, Error>) -> Void in
                switch result {
                case .success(let p):
                    let productsByYear = p.products.reduce(into: [String: [Product]]()) { productsByYear, product in
                        let year: String = String(product.productReleaseDate.split(separator: "-", maxSplits: 1)[0])
                        productsByYear[year, default: []].append(product)
                    }
                    
                    Task(priority: .userInitiated) { [productsByYear] in
                        await self.updateState(productsByYear: productsByYear)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @MainActor
    private func updateState(productsByYear: [String: [Product]]) {
        self.productsByYear = productsByYear
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if let productsByYear {
                    List(productsByYear.keys.sorted(by: >), id: \.self) { year in
                        if let productForYear = productsByYear[year] {
                            Section(header: Text(year).font(.headline).fontWeight(.black)) {
                                ForEach(productForYear, id: \.productId) { product in
                                    NavigationLink(value: ProductLinkDestinationValue(productID: product.productId, productName: product.productName), label: {
                                        ProductListItemView(product: product)
                                            .equatable()
                                    })
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .ignoresSafeArea(.keyboard)
                } else {
                    ProgressView()
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .frame(maxHeight: .infinity)
            .task(priority: .userInitiated) {
                await fetch()
            }
            .navigationTitle("Browse")
            .navigationDestination(for: CardLinkDestinationValue.self) { card in
                CardLinkDestinationView(cardLinkDestinationValue: card)
            }
            .navigationDestination(for: ProductLinkDestinationValue.self) { product in
                ProductLinkDestinationView(productLinkDestinationValue: product)
            }
        }
    }
}

#Preview {
    BrowseView()
}
