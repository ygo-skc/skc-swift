//
//  BrowseViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/15/24.
//

import Foundation

@MainActor
@Observable
final class ProductBrowseViewModel {
    var showFilters = false
    
    var productTypeFilters: [FilteredItem<String>] = []
    var productSubTypeFilters: [FilteredItem<String>] = []
    
    private(set) var dataError: NetworkError?
    private(set) var dataStatus = DataTaskStatus.uninitiated
    
    private(set) var filteredProducts: [String: [Product]] = [:]
    
    @ObservationIgnored
    private var products: [Product] = []
    
    @ObservationIgnored
    private var productTypeByProductSubType = [String: String]()
    
    @ObservationIgnored
    private var uniqueProductTypes = Set<String>()
    @ObservationIgnored
    private var uniqueProductSubTypes = Set<String>()
    
    @ObservationIgnored
    private var lastRefreshTimestamp = Date.distantPast
    
    func fetchProductBrowseData() async {
        if dataError != nil || dataStatus == .uninitiated || lastRefreshTimestamp.isDateInvalidated(10) {
            dataStatus = .pending
            switch await data(productsURL(), resType: Products.self) {
            case .success(let p):
                if products != p.products {
                    (uniqueProductTypes, uniqueProductSubTypes, productTypeByProductSubType, productTypeFilters) = await configureCriteria(products: p.products)
                    products = p.products
                }
                dataError = nil
                lastRefreshTimestamp = Date()
            case .failure(let error):
                dataError = error
            }
            dataStatus = .done
        }
    }
    
    func syncProductSubTypeFilters(insertions: [CollectionDifference<FilteredItem<String>>.Change]) async {
        // init case
        if insertions.count == uniqueProductTypes.count {
            productSubTypeFilters = uniqueProductSubTypes.sorted().map {
                FilteredItem(category: $0, isToggled: false, disableToggle: true)
            }
        } else if insertions.count > 0 {
            productSubTypeFilters = await updateProductSubTypeFilters(insertion: insertions.first, productSubTypeFilters: productSubTypeFilters,
                                                                      productTypeByProductSubType: productTypeByProductSubType)
        }
    }
    
    func updateProductList() async {
        let toggledProductSubTypes = Set(productSubTypeFilters.filter({ $0.isToggled }).map({ $0.category }))
        
        filteredProducts = ((toggledProductSubTypes.isEmpty) ? products : products.filter({toggledProductSubTypes.contains($0.productSubType)}))
            .reduce(into: [String: [Product]]()) { productsByYear, product in
                let year: String = String(product.productReleaseDate.split(separator: "-", maxSplits: 1)[0])
                productsByYear[year, default: []].append(product)
            }
    }
    
    nonisolated private func configureCriteria(products: [Product]) async -> (Set<String>, Set<String>, [String: String], [FilteredItem<String>]) {
        var uniqueProductTypes = Set<String>()
        var uniqueProductSubTypes = Set<String>()
        var productTypeByProductSubType = [String: String]()
        var productTypeFilters: [FilteredItem<String>] = []
        
        products.forEach { product in
            if !uniqueProductTypes.contains(product.productType) {
                uniqueProductTypes.insert(product.productType)
                productTypeFilters.append(FilteredItem(category: product.productType, isToggled: false, disableToggle: false))
            }
            
            if !uniqueProductSubTypes.contains(product.productSubType) {
                uniqueProductSubTypes.insert(product.productSubType)
                productTypeByProductSubType[product.productSubType] = product.productType
            }
        }
        
        return (uniqueProductTypes, uniqueProductSubTypes, productTypeByProductSubType, productTypeFilters)
    }
    
    nonisolated private func updateProductSubTypeFilters(insertion: CollectionDifference<FilteredItem<String>>.Change?, productSubTypeFilters: [FilteredItem<String>],
                                                         productTypeByProductSubType: [String: String]) async -> [FilteredItem<String>] {
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
}
