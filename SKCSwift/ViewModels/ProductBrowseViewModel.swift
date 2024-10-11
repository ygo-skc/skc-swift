//
//  BrowseViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/15/24.
//

import Foundation

@Observable
class ProductBrowseViewModel {
    var showFilters = false
    
    var productTypeFilters: [FilteredItem] = []
    var productSubTypeFilters: [FilteredItem] = []
    
    private(set) var productsByYear: [String: [Product]]?
    
    @ObservationIgnored
    private(set) var products: [Product]?
    
    @ObservationIgnored
    private var productTypeByProductSubType = [String: String]()
    
    @ObservationIgnored
    private var uniqueProductTypes = Set<String>()
    @ObservationIgnored
    private var uniqueProductSubTypes = Set<String>()
    
    @MainActor
    func fetchProductBrowseData() async {
        if products == nil {
            switch await data(Products.self, url: productsURL()) {
            case .success(let p):
                p.products.forEach { product in
                    self.uniqueProductTypes.insert(product.productType)
                    self.uniqueProductSubTypes.insert(product.productSubType)
                    self.productTypeByProductSubType[product.productSubType] = product.productType
                }
                self.products = p.products
                
                Task(priority: .userInitiated) { @MainActor in
                    self.productTypeFilters = self.uniqueProductTypes.sorted().reduce(into: [FilteredItem]()) {
                        $0.append(FilteredItem(category: $1, isToggled: true, disableToggle: false))
                    }
                }
            case .failure(_): break
            }
        }
    }
    
    @MainActor
    func syncProductSubTypeFilters(insertions: [CollectionDifference<FilteredItem>.Change]) async {
        let productSubTypeFilters: [FilteredItem]
        if insertions.count == uniqueProductTypes.count {   // init case
            productSubTypeFilters = uniqueProductSubTypes.sorted().reduce(into: [FilteredItem]()) {
                $0.append(FilteredItem(category: $1, isToggled: true, disableToggle: false))
            }
            
            Task { @MainActor in
                self.productSubTypeFilters = productSubTypeFilters
            }
        } else {
            if let c = insertions.first {
                switch c {
                case .insert(_, let changeElement, _):
                    productSubTypeFilters = self.productSubTypeFilters.map {
                        return (changeElement.category == productTypeByProductSubType[$0.category] ?? "") ?
                        FilteredItem(category: $0.category, isToggled: changeElement.isToggled, disableToggle: !changeElement.isToggled) : $0
                    }
                    
                    Task { @MainActor in
                        self.productSubTypeFilters = productSubTypeFilters
                    }
                default: break
                }
            }
        }
    }
    
    @MainActor
    func updateProductList() async {
        let toggledProductSubTypeFilters = Set(productSubTypeFilters.filter({ $0.isToggled }).map({ $0.category }))
        
        let productsByYear = products?
            .filter({toggledProductSubTypeFilters.contains($0.productSubType)})
            .reduce(into: [String: [Product]]()) { productsByYear, product in
                let year: String = String(product.productReleaseDate.split(separator: "-", maxSplits: 1)[0])
                productsByYear[year, default: []].append(product)
            }
        
        self.productsByYear = productsByYear
    }
}
