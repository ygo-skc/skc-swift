//
//  BrowseViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/15/24.
//

import Foundation

@Observable
final class ProductBrowseViewModel {
    var showFilters = false
    
    var productTypeFilters: [FilteredItem] = []
    var productSubTypeFilters: [FilteredItem] = []
    
    private(set) var dataError: NetworkError?
    private(set) var dataStatus = DataTaskStatus.uninitiated
    
    private(set) var areProductsFiltered = false
    private(set) var filteredProducts: [String: [Product]] = [:]
    
    @ObservationIgnored
    private var products: [Product] = []
    
    @ObservationIgnored
    private var productTypeByProductSubType = [String: String]()
    
    @ObservationIgnored
    private var uniqueProductTypes = Set<String>()
    @ObservationIgnored
    private var uniqueProductSubTypes = Set<String>()
    
    @MainActor
    func fetchProductBrowseData() async {
        if dataError != nil || products.isEmpty {
            switch await data(Products.self, url: productsURL()) {
            case .success(let p):
                (uniqueProductTypes, uniqueProductSubTypes, productTypeByProductSubType, productTypeFilters) = await ProductBrowseViewModel
                    .configureProductBrowseData(products: p.products)
                products = p.products
                dataError = nil
            case .failure(let error):
                dataError = error
            }
            dataStatus = .done
        }
    }
    
    @MainActor
    func syncProductSubTypeFilters(insertions: [CollectionDifference<FilteredItem>.Change]) async {
        areProductsFiltered = false
        // init case
        if insertions.count == uniqueProductTypes.count {
            productSubTypeFilters = await ProductBrowseViewModel.initProductSubTypeFilters(uniqueProductSubTypes: uniqueProductSubTypes)
        } else {
            productSubTypeFilters = await ProductBrowseViewModel.updateProductSubTypeFilters(insertion: insertions.first, productSubTypeFilters: productSubTypeFilters,
                                                                                             productTypeByProductSubType: productTypeByProductSubType)
        }
    }
    
    @MainActor
    func updateProductList() async {
        filteredProducts = await ProductBrowseViewModel.filteredProducts(productSubTypeFilters: productSubTypeFilters, products: products)
        areProductsFiltered = true
    }
    
    private static func configureProductBrowseData(products: [Product]) async -> (Set<String>, Set<String>, [String: String], [FilteredItem]) {
        var uniqueProductTypes = Set<String>()
        var uniqueProductSubTypes = Set<String>()
        var productTypeByProductSubType = [String: String]()
        var productTypeFilters: [FilteredItem] = []
        
        products.forEach { product in
            uniqueProductTypes.insert(product.productType)
            uniqueProductSubTypes.insert(product.productSubType)
            productTypeByProductSubType[product.productSubType] = product.productType
        }
        
        productTypeFilters = uniqueProductTypes.sorted().reduce(into: [FilteredItem]()) {
            $0.append(FilteredItem(category: $1, isToggled: true, disableToggle: false))
        }
        
        return (uniqueProductTypes, uniqueProductSubTypes, productTypeByProductSubType, productTypeFilters)
    }
    
    private static func initProductSubTypeFilters(uniqueProductSubTypes: Set<String>) async -> [FilteredItem] {
        return uniqueProductSubTypes.sorted().reduce(into: [FilteredItem]()) {
            $0.append(FilteredItem(category: $1, isToggled: true, disableToggle: false))
        }
    }
    
    private static func updateProductSubTypeFilters(insertion: CollectionDifference<FilteredItem>.Change?, productSubTypeFilters: [FilteredItem],
                                                    productTypeByProductSubType: [String: String]) async -> [FilteredItem] {
        switch insertion {
        case .insert(_, let changeElement, _):
            return productSubTypeFilters.map {
                return (changeElement.category == productTypeByProductSubType[$0.category]) ?
                FilteredItem(category: $0.category, isToggled: changeElement.isToggled, disableToggle: !changeElement.isToggled) : $0
            }
        default:
            return []
        }
    }
    
    private static func filteredProducts(productSubTypeFilters: [FilteredItem], products: [Product]?) async -> [String : [Product]] {
        let toggledProductSubTypeFilters = Set(productSubTypeFilters.filter({ $0.isToggled }).map({ $0.category }))
        
        return products?
            .filter({toggledProductSubTypeFilters.contains($0.productSubType)})
            .reduce(into: [String: [Product]]()) { productsByYear, product in
                let year: String = String(product.productReleaseDate.split(separator: "-", maxSplits: 1)[0])
                productsByYear[year, default: []].append(product)
            } ?? [:]
    }
}
