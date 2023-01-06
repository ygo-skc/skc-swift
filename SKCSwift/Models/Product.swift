//
//  Product.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/3/23.
//

import Foundation

struct Product: Codable {
    var productId: String
    var productLocale: String
    var productName: String
    var productType: String
    var productSubType: String
    var productReleaseDate: String
    var productContent: [ProductContent]
}

struct ProductContent: Codable {
    var productPosition: String
    var rarities: [String]
}
