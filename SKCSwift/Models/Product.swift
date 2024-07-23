//
//  Product.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/3/23.
//

struct Product: Codable {
    let productId, productLocale, productName, productType, productSubType, productReleaseDate: String
    let productContent: [ProductContent]?
}

struct ProductContent: Codable {
    var productPosition: String
    var rarities: [String]
}
