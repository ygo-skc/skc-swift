//
//  ProductViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 11/11/24.
//

import Foundation

@Observable
final class ProductViewModel {
    let productID: String
    
    private(set) var product: Product? = nil
    private(set) var suggestions: ProductSuggestions? = nil
    
    init(productID: String) {
        self.productID = productID
    }
    
    @MainActor
    func fetchProductData() async {
        if product == nil {
            switch await data(Product.self, url: productInfoURL(productID: productID)) {
            case .success(let product):
                self.product = product
            case .failure(_): break
            }
        }
    }
    
    @MainActor
    func fetchProductSuggestions() async {
        if suggestions == nil {
            switch await data(ProductSuggestions.self, url: productSuggestionsURL(productID: productID)) {
            case .success(let suggestions):
                self.suggestions = suggestions
            case .failure(_): break
            }
        }
    }
    
    enum ProductModelDataType {
        case product, suggestions
    }
}
