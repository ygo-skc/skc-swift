//
//  Product.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/3/23.
//

struct Product: Codable, Equatable, Identifiable {
    let productId, productLocale, productName, productType, productSubType, productReleaseDate: String
    let productTotal: Int?
    let productContent: [ProductContent]?
    
    var id: String {
        if !(productContent?.isEmpty ?? true), let productContent {
            return "\(productId)-\(productContent[0].id)"
        } else {
            return productId
        }
    }
    
    nonisolated func productIDWithContentTotal() -> String {
        if let productTotal {
            return "\(productId) │ \(productTotal) Cards"
        }
        return productId
    }
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


struct ProductContent: Codable, Equatable, Identifiable {
    let card: Card?
    let productPosition: String
    let rarities: [String]
    
    var id: String {
        if let card {
            return card.cardID + productPosition + String(rarities.hashValue)
        } else {
            return productPosition + String(rarities.hashValue)
        }
    }
}

extension ProductContent {
    init(productPosition: String, rarities: [String]) {
        self.init(card: nil, productPosition: productPosition, rarities: rarities)
    }
}

struct Products: Codable, Equatable {
    let locale: String
    let products: [Product]
}

// used as convenience when working with NavigationDestination
struct ProductLinkDestinationValue: Hashable {
    let productID: String
    let productName: String
}
