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
    
    @ObservationIgnored
    var hasSuggestions: Bool {
        if let suggestions {
            return suggestions.hasSuggestions
        } else {
            return false
        }
    }
    
    func fetchProductData(forceRefresh: Bool = false) async {
        guard forceRefresh || product == nil else { return }
        (productNE, productDTS) = (nil, .pending)
        (productNE, productDTS) = await data(productInfoURL(productID: productID), resType: Product.self)
            .validate(&product)
    }
    
    func fetchProductSuggestions(forceRefresh: Bool = false) async {
        guard forceRefresh || suggestions == nil else { return }
        (suggestionsNE, suggestionsDTS) = (nil, .pending)
        (suggestionsNE, suggestionsDTS) = await data(productSuggestionsURL(productID: productID), resType: ProductSuggestions.self)
            .validate(&suggestions)
    }
}
