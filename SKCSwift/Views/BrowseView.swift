//
//  BrowseView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/11/24.
//

import SwiftUI

struct BrowseView: View {
    @State private var focusedResource = TrendingResourceType.card
    
    @State private var productBrowseViewModel = ProductBrowseViewModel()
    @State private var cardBrowseViewModel = CardBrowseViewModel()
    
    private var noBrowseResults: String {
        switch focusedResource {
        case .card:
            return "There are over 12k cards available to browse, try filtering to narrow down your search"
        case .product:
            return "No filters selected - what were you expecting to see 🤔"
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Select resource to browse", selection: $focusedResource) {
                    ForEach(TrendingResourceType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                switch focusedResource == .product ? productBrowseViewModel.status : cardBrowseViewModel.status {
                case .pending:
                    ProgressView("Loading...")
                        .controlSize(.large)
                        .task(priority: .userInitiated) {
                            switch focusedResource {
                            case .card:
                                await cardBrowseViewModel.fetchCardBrowseCriteria()
                            case .product:
                                await productBrowseViewModel.fetchProductBrowseData()
                            }
                        }
                        .frame(maxHeight: .infinity)
                case .done, .error:
                    if (focusedResource == .product && productBrowseViewModel.areProductsFiltered && productBrowseViewModel.filteredProducts.isEmpty) ||
                        (focusedResource == .card && cardBrowseViewModel.cards.isEmpty) {
                        ContentUnavailableView(noBrowseResults, systemImage: "exclamationmark.square.fill")
                    } else {
                        ScrollView {
                            switch focusedResource {
                            case .card:
                                CardBrowseView(filteredCards: cardBrowseViewModel.cards)
                            case .product:
                                ProductBrowseView(filteredProducts: productBrowseViewModel.filteredProducts)
                            }
                        }
                    }
                }
            }
            .toolbar {
                switch focusedResource {
                case .card:
                    FilterButton(showFilters: $cardBrowseViewModel.showFilters) {
                        if let filters = Binding<CardFilters>($cardBrowseViewModel.filters) {
                            CardFiltersView(filters: filters)
                        }
                    }
                case .product:
                    FilterButton(showFilters: $productBrowseViewModel.showFilters) {
                        ProductFiltersView(
                            productTypeFilters: $productBrowseViewModel.productTypeFilters,
                            productSubTypeFilters: $productBrowseViewModel.productSubTypeFilters)
                    }
                }
            }
            .navigationTitle("Browse")
            .navigationDestination(for: CardLinkDestinationValue.self) { card in
                CardLinkDestinationView(cardLinkDestinationValue: card)
            }
            .navigationDestination(for: ProductLinkDestinationValue.self) { product in
                ProductLinkDestinationView(productLinkDestinationValue: product)
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
            .onChange(of: cardBrowseViewModel.filters) {
                Task {
                    await cardBrowseViewModel.fetchCards()
                }
            }
        }
    }
}

private struct ProductBrowseView: View {
    let filteredProducts: [String: [Product]]
    
    var body: some View {
        LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
            ForEach(filteredProducts.keys.sorted(by: >), id: \.self) { year in
                if let filteredProducts = filteredProducts[year] {
                    Section(header: HeaderView(header: "\(year) • \(filteredProducts.count) total")) {
                        LazyVStack {
                            ForEach(filteredProducts, id: \.productId) { product in
                                NavigationLink(
                                    value: ProductLinkDestinationValue(productID: product.productId, productName: product.productName),
                                    label: {
                                        GroupBox {
                                            ProductListItemView(product: product)
                                                .equatable()
                                        }
                                        .groupBoxStyle(.listItem)
                                    })
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .ignoresSafeArea(.keyboard)
        }
        .modifier(ParentViewModifier())
    }
}

private struct CardBrowseView: View {
    let filteredCards: [Card]
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            ForEach(filteredCards, id: \.self.cardID) { card in
                NavigationLink(value: CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName), label: {
                    GroupBox {
                        CardListItemView(card: card)
                            .equatable()
                    }
                    .groupBoxStyle(.listItem)
                })
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
            .ignoresSafeArea(.keyboard)
        }
        .modifier(ParentViewModifier())
    }
}

private struct ProductFiltersView: View {
    @Binding var productTypeFilters: [FilteredItem]
    @Binding var productSubTypeFilters: [FilteredItem]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Product filters")
                .font(.title2)
            Text("Filter products by type or sub-type, by default every filter is enabled - try disabling some to tune to your liking 😉")
                .font(.headline)
                .fontWeight(.light)
                .padding(.bottom)
            
            ProductFilterView(filters: $productTypeFilters,
                              filterInfo: "Narrow down products",
                              filterImage: "1.circle",
                              columns: Array(repeating: GridItem(.flexible()), count: 4))
            ProductFilterView(filters: $productSubTypeFilters,
                              filterInfo: "Choose specific product category",
                              filterImage: "2.circle",
                              columns: Array(repeating: GridItem(.flexible()), count: 2))
        }
        .modifier(ParentViewModifier())
        .padding(.top)
    }
}

private struct ProductFilterView: View {
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

private struct CardFiltersView: View {
    @Binding var filters: CardFilters
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Card filters")
                .font(.title2)
            Text("Filter cards by using card metadata")
                .font(.headline)
                .fontWeight(.light)
                .padding(.bottom)
            
            CardFilterView(filters: $filters.colors, filterInfo: "Filter by card color") { category in
                CardColorIndicatorView(cardColor: category, variant: .large)
            }
            CardFilterView(filters: $filters.attributes, filterInfo: "Filter by attribute") { category in
                AttributeView(attribute: Attribute(rawValue: category) ?? .unknown)
            }
        }
        .modifier(ParentViewModifier())
        .padding(.top)
    }
}

private struct CardFilterView<Content: View>: View {
    @Binding var filters: [FilteredItem]
    let filterInfo: String
    @ViewBuilder let content: (String) -> Content
    
    var body: some View {
        GroupBox {
            GroupBox {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6)) {
                    ForEach($filters) { $cardColorFilter in
                        Toggle(isOn: $cardColorFilter.isToggled) {
                            content(cardColorFilter.category)
                        }
                        .modifier(.buttonToggle)
                    }
                }
            }
            .groupBoxStyle(.filtersSubGroup)
        } label: {
            Text(filterInfo)
        }
        .groupBoxStyle(.filters)
        .padding(.bottom)
    }
}

private struct FilterButton<Content: View>: View {
    @Binding var showFilters: Bool
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        Button {
            showFilters.toggle()
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
        }
        .sheet(isPresented: $showFilters, onDismiss: { showFilters = false }) {
            content()
        }
    }
}

#Preview {
    BrowseView()
}
