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
    
    private(set) var requestErrors: [ProductModelDataType: NetworkError?] = [:]
    
    private(set) var product: Product? = nil
    private(set) var suggestions: ProductSuggestions? = nil
    
    init(productID: String) {
        self.productID = productID
    }
    
    @MainActor
    func fetchProductData(forceRefresh: Bool = false) async {
        if forceRefresh || product == nil {
            switch await data(productInfoURL(productID: productID), resType: Product.self) {
            case .success(let product):
                self.product = product
                requestErrors[.product] = nil
            case .failure(let error):
                requestErrors[.product] = error
            }
        }
    }
    
    @MainActor
    func fetchProductSuggestions(forceRefresh: Bool = false) async {
        if forceRefresh || suggestions == nil {
            switch await data(productSuggestionsURL(productID: productID), resType: ProductSuggestions.self) {
            case .success(let suggestions):
                self.suggestions = suggestions
                requestErrors[.suggestions] = nil
            case .failure(let error):
                requestErrors[.suggestions] = error
            }
        }
    }
    
    func hasSuggestions() -> Bool {
        if let namedMaterials = suggestions?.suggestions.namedMaterials, let namedReferences = suggestions?.suggestions.namedReferences,
           let referencedBy = suggestions?.support.referencedBy, let materialFor = suggestions?.support.materialFor,
            namedMaterials.isEmpty && namedReferences.isEmpty && referencedBy.isEmpty && materialFor.isEmpty {
            return false
        }
        return true
    }
    
    func resetProductError() {
        requestErrors[.product] = nil
    }
    
    func resetSuggestionErrors() {
        requestErrors[.suggestions] = nil
    }
    
    enum ProductModelDataType {
        case product, suggestions
    }
}
