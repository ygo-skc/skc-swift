//
//  ProductViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 11/11/24.
//

import Foundation

@Observable
final class ProductViewModel {
    @ObservationIgnored
    let productID: String
    
    init(productID: String) {
        self.productID = productID
    }
    
    private(set) var productDTS: DataTaskStatus = .pending
    private(set) var suggestionsDTS: DataTaskStatus = .pending
    
    @ObservationIgnored
    private(set) var productNE: NetworkError?
    @ObservationIgnored
    private(set) var suggestionsNE: NetworkError?
    
    @ObservationIgnored
    private(set) var product: Product? = nil
    @ObservationIgnored
    private(set) var suggestions: ProductSuggestions? = nil
    
    func fetchProductData(forceRefresh: Bool = false) async {
        if forceRefresh || product == nil {
            productDTS = .pending
            let res = await data(productInfoURL(productID: productID), resType: Product.self)
            if case .success(let product) = res {
                self.product = product
            }
            (productNE, productDTS) = res.validate()
        }
    }
    
    func fetchProductSuggestions(forceRefresh: Bool = false) async {
        if forceRefresh || suggestions == nil {
            suggestionsDTS = .pending
            let res = await data(productSuggestionsURL(productID: productID), resType: ProductSuggestions.self)
            if case .success(let suggestions) = res {
                self.suggestions = suggestions
            }
            (suggestionsNE, suggestionsDTS) = res.validate()
        }
    }
}
