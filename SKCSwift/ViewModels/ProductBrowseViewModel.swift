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
        if dataError != nil || dataStatus == .uninitiated {
            dataStatus = .pending
            switch await data(productsURL(), resType: Products.self) {
            case .success(let p):
                (uniqueProductTypes, uniqueProductSubTypes, productTypeByProductSubType, productTypeFilters) = await configureProductBrowseData(products: p.products)
                products = p.products
                dataError = nil
            case .failure(let error):
                dataError = error
            }
            dataStatus = .done
        }
    }
    
    @MainActor
    func syncProductSubTypeFilters(insertions: [CollectionDifference<FilteredItem<String>>.Change]) async {
        areProductsFiltered = false
        // init case
        if insertions.count == uniqueProductTypes.count {
            productSubTypeFilters = uniqueProductSubTypes.sorted().reduce(into: [FilteredItem]()) {
                $0.append(FilteredItem(category: $1, isToggled: true, disableToggle: false))
            }
        } else {
            productSubTypeFilters = await updateProductSubTypeFilters(insertion: insertions.first, productSubTypeFilters: productSubTypeFilters,
                                                                                             productTypeByProductSubType: productTypeByProductSubType)
        }
    }
    
    @MainActor
    func updateProductList() async {
        let toggledProductSubTypeFilters = Set(productSubTypeFilters.filter({ $0.isToggled }).map({ $0.category }))
        
        filteredProducts = products
            .filter({toggledProductSubTypeFilters.contains($0.productSubType)})
            .reduce(into: [String: [Product]]()) { productsByYear, product in
                let year: String = String(product.productReleaseDate.split(separator: "-", maxSplits: 1)[0])
                productsByYear[year, default: []].append(product)
            }
        
        areProductsFiltered = true
    }
    
    @MainActor
    private func configureProductBrowseData(products: [Product]) async -> (Set<String>, Set<String>, [String: String], [FilteredItem<String>]) {
        var uniqueProductTypes = Set<String>()
        var uniqueProductSubTypes = Set<String>()
        var productTypeByProductSubType = [String: String]()
        var productTypeFilters: [FilteredItem<String>] = []
        
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
    
    @MainActor
    private func updateProductSubTypeFilters(insertion: CollectionDifference<FilteredItem<String>>.Change?, productSubTypeFilters: [FilteredItem<String>],
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
