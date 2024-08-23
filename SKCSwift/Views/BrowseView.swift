//
//  BrowseView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/11/24.
//

import SwiftUI

struct BrowseView: View {
    @State private var showFiltersSheet = false
    @State private var productBrowseViewModel = ProductBrowseViewModel()
    @State private var cardBrowseViewModel = CardBrowseViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                ProductBrowseView(productsByYear: productBrowseViewModel.productsByYear)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle("Browse")
            .navigationDestination(for: CardLinkDestinationValue.self) { card in
                CardLinkDestinationView(cardLinkDestinationValue: card)
            }
            .navigationDestination(for: ProductLinkDestinationValue.self) { product in
                ProductLinkDestinationView(productLinkDestinationValue: product)
            }
            .toolbar {
                Button {
                    showFiltersSheet.toggle()
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                }
                .sheet(isPresented: $showFiltersSheet, onDismiss: {showFiltersSheet = false}) {
                    ProductFilters(
                        productTypeFilters: $productBrowseViewModel.productTypeFilters,
                        productSubTypeFilters: $productBrowseViewModel.productSubTypeFilters)
                }
                
                Button {
                    showFiltersSheet.toggle()
                } label: {
                    Image(systemName: "folder")
                }
                .sheet(isPresented: $showFiltersSheet, onDismiss: {showFiltersSheet = false}) {
                    CardFilters(cardColorFilters: $cardBrowseViewModel.cardColorFilters)
                }
            }
            .onChange(of: productBrowseViewModel.productTypeFilters) { oldValue, newValue in
                Task {
                    await productBrowseViewModel.syncProductSubTypeFilters(insertions: newValue.difference(from: oldValue).insertions)
                }
            }
            .onChange(of: productBrowseViewModel.productSubTypeFilters) {
                Task {
                    await productBrowseViewModel.updateProductList()
                }
            }
            .task(priority: .userInitiated) {
                await productBrowseViewModel.fetchProductBrowseData()
            }
            .task(priority: .userInitiated) {
                await cardBrowseViewModel.fetchCardBrowseCriteria()
            }
        }
    }
}

private struct ProductBrowseView: View {
    let productsByYear: [String: [Product]]?
    
    var body: some View {
        if let productsByYear = productsByYear, productsByYear.isEmpty {
            ContentUnavailableView("No filters selected - what were you expecting to see 🤔", systemImage: "exclamationmark.square.fill")
        } else if let productsByYear = productsByYear, !productsByYear.isEmpty {
            List(productsByYear.keys.sorted(by: >), id: \.self) { year in
                if let productForYear = productsByYear[year] {
                    Section(header: Text("\(year) • \(productForYear.count) total").font(.headline).fontWeight(.black)) {
                        ForEach(productForYear, id: \.productId) { product in
                            NavigationLink(value: ProductLinkDestinationValue(productID: product.productId, productName: product.productName), label: {
                                ProductListItemView(product: product)
                                    .equatable()
                            })
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .ignoresSafeArea(.keyboard)
        } else {
            ProgressView()
        }
    }
}

private struct ProductFilters: View {
    @Binding var productTypeFilters: [FilteredItem]
    @Binding var productSubTypeFilters: [FilteredItem]
    
    private static let productTypeColumns = Array(repeating: GridItem(.flexible()), count: 4)
    private static let productSubTypeColumns = Array(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Product filters")
                .font(.title2)
            Text("Filter products by type or sub-type, by default every filter is enabled - try disabling some to tune to your liking 😉")
                .font(.headline)
                .fontWeight(.light)
                .padding(.bottom)
            
            ProductFilter(filters: $productTypeFilters,
                          filterInfo: "Narrow down products",
                          filterImage: "1.circle",
                          columns: ProductFilters.productTypeColumns)
            ProductFilter(filters: $productSubTypeFilters,
                          filterInfo: "Choose specific product category",
                          filterImage: "2.circle",
                          columns: ProductFilters.productSubTypeColumns)
        }
        .modifier(ParentViewModifier())
        .padding(.top)
    }
}

private struct ProductFilter: View {
    @Binding var filters: [FilteredItem]
    let filterInfo: String
    let filterImage: String
    let columns: [GridItem]
    
    var body: some View {
        GroupBox {
            GroupBox {
                LazyVGrid(columns: columns) {
                    ForEach($filters) { $pt in
                        Toggle(isOn: $pt.isToggled) {
                            Text(pt.category)
                                .modifier(.buttonToggleText)
                        }
                        .disabled(pt.disableToggle)
                        .modifier(.buttonToggle)
                    }
                }
            }
            .groupBoxStyle(.filtersSubGroup)
        } label: {
            Label(filterInfo, systemImage: filterImage)
        }
        .groupBoxStyle(.filters)
        .padding(.bottom)
    }
}

private struct CardFilters: View {
    @Binding var cardColorFilters: [FilteredItem]
    
    var body: some View {
        VStack {
            GroupBox {
                GroupBox {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6)) {
                        ForEach($cardColorFilters) { $cardColorFilter in
                            Toggle(isOn: $cardColorFilter.isToggled) {
                                CardColorIndicatorView(cardColor: cardColorFilter.category, variant: .large)
                            }
                            .modifier(.buttonToggle)
                        }
                    }
                }
                .groupBoxStyle(.filtersSubGroup)
            } label: {
                Text("Filter by card color")
            }
            .groupBoxStyle(.filters)
            .padding(.bottom)
        }
    }
}

#Preview {
    BrowseView()
}
