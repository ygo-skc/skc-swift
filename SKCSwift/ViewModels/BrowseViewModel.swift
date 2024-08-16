//
//  BrowseViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/15/24.
//

import Foundation

struct FilteredItem: Identifiable, Equatable {
    let category: String
    var enabled: Bool
    var disableToggle: Bool
    
    var id: String {
        return category
    }
}

@Observable
class BrowseViewModel {
    private(set) var productsByYear: [String: [Product]]?
    var productTypeFilters: [FilteredItem] = []
    var productSubTypeFilters: [FilteredItem] = []
    
    private var productTypeByProductSubType = [String: String]()
    
    func fetchProductBrowseData() async {
        if productsByYear == nil {
            request(url: productsURL(), priority: 0.4) { (result: Result<Products, Error>) -> Void in
                switch result {
                case .success(let p):
                    var uniqueProductTypes = Set<String>()
                    var uniqueProductSubTypes = Set<String>()
                    
                    let productsByYear = p.products.reduce(into: [String: [Product]]()) { productsByYear, product in
                        let year: String = String(product.productReleaseDate.split(separator: "-", maxSplits: 1)[0])
                        productsByYear[year, default: []].append(product)
                        
                        uniqueProductTypes.insert(product.productType)
                        uniqueProductSubTypes.insert(product.productSubType)
                        
                        self.productTypeByProductSubType[product.productSubType] = product.productType
                    }
                    
                    Task(priority: .userInitiated) { [productsByYear, uniqueProductTypes, uniqueProductSubTypes] in
                        await self.resetFilters(productsByYear: productsByYear,
                                                uniqueProductTypes: uniqueProductTypes, uniqueProductSubTypes: uniqueProductSubTypes)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @MainActor
    func resetFilters(productsByYear: [String: [Product]], uniqueProductTypes: Set<String>, uniqueProductSubTypes: Set<String>) {
        self.productTypeFilters = uniqueProductTypes.sorted().reduce(into: [FilteredItem]()) {
            $0.append(FilteredItem(category: $1, enabled: false, disableToggle: false))
        }
        self.productSubTypeFilters = uniqueProductSubTypes.sorted().reduce(into: [FilteredItem]()) {
            $0.append(FilteredItem(category: $1, enabled: false, disableToggle: false))
        }
        self.productsByYear = productsByYear
    }
    
    @MainActor
    func syncProductSubTypeFilters() {
        let enabledProductTypeFilters = Set(productTypeFilters.filter({ $0.enabled }).map({ $0.category }))
        
        for index in productSubTypeFilters.indices {
            if enabledProductTypeFilters.contains(productTypeByProductSubType[productSubTypeFilters[index].category] ?? "")  {
                productSubTypeFilters[index].disableToggle = false
            } else {
                if enabledProductTypeFilters.isEmpty {
                    productSubTypeFilters[index].disableToggle = false
                } else {
                    productSubTypeFilters[index].disableToggle = true
                    productSubTypeFilters[index].enabled = false
                }
            }
        }
        
    }
}
