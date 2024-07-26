//
//  Product.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/3/23.
//

struct Product: Codable, Equatable {
    let productId, productLocale, productName, productType, productSubType, productReleaseDate: String
    let productTotal: Int?
    let productContent: [ProductContent]?
    
    func productIDWithContentTotal() -> String {
        if let productTotal {
            return "\(productId) │ \(productTotal) Cards"
        }
        return productId
    }
}

struct ProductContent: Codable, Equatable {
    var productPosition: String
    var rarities: [String]
}

extension Product {
    init(productId: String, productLocale: String, productName: String, productType: String, productSubType: String, productReleaseDate: String, productTotal: Int) {
        self.init(productId: productId, productLocale: productLocale, productName: productName, productType: productType,
                  productSubType: productSubType, productReleaseDate: productReleaseDate, productTotal: productTotal, productContent: [])
    }
    init(productId: String, productLocale: String, productName: String, productType: String, productSubType: String, productReleaseDate: String, productContent: [ProductContent]) {
        self.init(productId: productId, productLocale: productLocale, productName: productName, productType: productType,
                  productSubType: productSubType, productReleaseDate: productReleaseDate, productTotal: productContent.count, productContent: productContent)
    }
}
