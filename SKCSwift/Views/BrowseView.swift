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
                if let productsByYear = browseViewModel.productsByYear {
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
            .frame(maxHeight: .infinity, alignment: .top)
            .frame(maxHeight: .infinity)
            .task(priority: .userInitiated) {
                await browseViewModel.fetchProductBrowseData()
            }
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
            .onChange(of: browseViewModel.productTypeFilters) {
                browseViewModel.syncProductSubTypeFilters()
            }
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
            Text("Filter out products by either its main product type and/or its sub-type")
                .font(.subheadline)
                .padding(.bottom)
            GroupBox {
                GroupBox {
                    LazyVGrid(columns: columns) {
                        ForEach($productTypeFilters) { $pt in
                            Toggle(isOn: $pt.enabled) {
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
                Label("Product type", systemImage: "1.circle")
            }
            .groupBoxStyle(.filters)
            .padding(.bottom)
            
            GroupBox {
                GroupBox {
                    LazyVGrid(columns: columns2) {
                        ForEach($productSubTypeFilters) { $pt in
                            Toggle(isOn: $pt.enabled) {
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
                Label("Product sub-type", systemImage: "2.circle")
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
