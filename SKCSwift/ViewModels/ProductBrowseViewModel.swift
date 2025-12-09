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
    
    var productTypeFilters: [FilteredItem<String>] = []
    var productSubTypeFilters: [FilteredItem<String>] = []
    
    private(set) var dataError: NetworkError?
    private(set) var dataStatus = DataTaskStatus.pending
    
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
        if dataError != nil || dataStatus == .pending || lastRefreshTimestamp.isDateInvalidated(10) {
            dataStatus = .pending
            switch await data(productsURL(), resType: Products.self) {
            case .success(let p):
                if p.products.isEmpty {
                    dataError = .notFound
                } else {
                    products = p.products
                    (uniqueProductTypes, uniqueProductSubTypes, productTypeByProductSubType, productTypeFilters) = await configureCriteria(products: products)
                    dataError = nil
                }
            case .failure(let error):
                dataError = error
            }
            lastRefreshTimestamp = Date()
            dataStatus = .done
        }
    }
    
    func syncProductSubTypeFilters(insertions: [CollectionDifference<FilteredItem<String>>.Change]) async {
        // init case
        if insertions.count == uniqueProductTypes.count {
            productSubTypeFilters = uniqueProductSubTypes.sorted().map {
                FilteredItem(category: $0, isToggled: false, disableToggle: false)
            }
        } else {
            let change = insertions.first!
            let toggledProductTypes = Set(productTypeFilters.filter{ $0.isToggled }.map{ $0.category })
            productSubTypeFilters = await updateProductSubTypeFilters(change: change,
                                                                      toggledProductTypes: toggledProductTypes,
                                                                      productSubTypeFilters: productSubTypeFilters,
                                                                      productTypeByProductSubType: productTypeByProductSubType)
        }
    }
    
    func updateProductList() async {
        let toggledProductSubTypes = Set(productSubTypeFilters.filter{ $0.isToggled }.map{ $0.category })
        let p = (toggledProductSubTypes.isEmpty) ? products : products.filter { toggledProductSubTypes.contains($0.productSubType) }
        filteredProducts = Dictionary(grouping: p) { String($0.productReleaseDate.split(separator: "-", maxSplits: 1)[0]) }
    }
    
    @concurrent
    private func configureCriteria(products: [Product]) async -> (Set<String>, Set<String>, [String: String], [FilteredItem<String>]) {
        var uniqueProductTypes = Set<String>()
        var uniqueProductSubTypes = Set<String>()
        var productTypeByProductSubType = [String: String]()
        var productTypeFilters: [FilteredItem<String>] = []
        
        for product in products {
            if uniqueProductSubTypes.insert(product.productSubType).inserted {
                productTypeByProductSubType[product.productSubType] = product.productType
                
                if uniqueProductTypes.insert(product.productType).inserted {
                    productTypeFilters.append(FilteredItem(
                        category: product.productType,
                        isToggled: false,
                        disableToggle: false))
                }
            }
        }
        
        return (uniqueProductTypes, uniqueProductSubTypes, productTypeByProductSubType, productTypeFilters)
    }
    
    @concurrent
    private func updateProductSubTypeFilters(change: CollectionDifference<FilteredItem<String>>.Change,
                                             toggledProductTypes: Set<String>,
                                             productSubTypeFilters: [FilteredItem<String>],
                                             productTypeByProductSubType: [String: String]) async -> [FilteredItem<String>] {
        switch change {
        case .insert(_, let changeElement, _):
            return productSubTypeFilters.map {
                if toggledProductTypes.isEmpty {
                    return FilteredItem(category: $0.category, isToggled: false, disableToggle: false)
                } else if changeElement.category == productTypeByProductSubType[$0.category] {
                    return FilteredItem(category: $0.category, isToggled: changeElement.isToggled, disableToggle: !changeElement.isToggled)
                } else if let t = productTypeByProductSubType[$0.category], toggledProductTypes.contains(t) {
                    return FilteredItem(category: $0.category, isToggled: $0.isToggled, disableToggle: $0.disableToggle)
                } else {
                    return FilteredItem(category: $0.category, isToggled: false, disableToggle: true)
                }
            }
        default:
            return []
        }
    }
}
