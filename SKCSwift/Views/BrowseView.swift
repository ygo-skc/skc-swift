//
//  BrowseView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/11/24.
//

import SwiftUI

struct BrowseView: View {
    @State private var showFiltersSheet = false
    @State private var browseViewModel = BrowseViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                ProductBrowseView(productsByYear: browseViewModel.productsByYear)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .frame(maxHeight: .infinity)
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
                        productTypeFilters: $browseViewModel.productTypeFilters,
                        productSubTypeFilters: $browseViewModel.productSubTypeFilters)
                }
            }
            .onChange(of: browseViewModel.productTypeFilters) { oldValue, newValue in
                Task {
                    await browseViewModel.syncProductSubTypeFilters(insertions: newValue.difference(from: oldValue).insertions)
                }
            }
            .onChange(of: browseViewModel.productSubTypeFilters) {
                Task {
                    await browseViewModel.updateProductList()
                }
            }
            .task(priority: .userInitiated) {
                await browseViewModel.fetchProductBrowseData()
            }
            .task(priority: .userInitiated) {
                await browseViewModel.fetchCardBrowseCriteria()
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
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)
    private let columns2 = Array(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Product filters")
                .font(.title2)
            Text("Filter products by type or sub-type, by default every filter is enabled - try disabling some to tune to your liking 😉")
                .font(.headline)
                .fontWeight(.light)
                .padding(.bottom)
            GroupBox {
                GroupBox {
                    LazyVGrid(columns: columns) {
                        ForEach($productTypeFilters) { $pt in
                            Toggle(isOn: $pt.isToggled) {
                                Text(pt.category)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                    .contentShape(Rectangle())
                            }
                            .disabled(pt.disableToggle)
                            .toggleStyle(.button)
                            .frame(maxWidth: .infinity)
                            .tint(.primary)
                        }
                    }
                }
                .groupBoxStyle(.filtersSubGroup)
            } label: {
                Label("Narrow down products", systemImage: "1.circle")
            }
            .groupBoxStyle(.filters)
            .padding(.bottom)
            
            GroupBox {
                GroupBox {
                    LazyVGrid(columns: columns2) {
                        ForEach($productSubTypeFilters) { $pt in
                            Toggle(isOn: $pt.isToggled) {
                                Text(pt.category)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                    .contentShape(Rectangle())
                            }
                            .disabled(pt.disableToggle)
                            .toggleStyle(.button)
                            .frame(maxWidth: .infinity)
                            .tint(.primary)
                        }
                    }
                }
                .groupBoxStyle(.filtersSubGroup)
            } label: {
                Label("Choose specific product category", systemImage: "2.circle")
            }
            .groupBoxStyle(.filters)
        }
        .modifier(ParentViewModifier())
        .padding(.top)
    }
}

#Preview {
    BrowseView()
}
