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
    
    var body: some View {
        VStack{
            
        }
        .onAppear {
            request(url: productInfoURL(productID: productID), priority: 0.2) { (result: Result<Product, Error>) -> Void in
                switch result {
                case .success(let product):
                    DispatchQueue.main.async {
                        print(product)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

#Preview {
    ProductView(productID: "LEDE")
}
