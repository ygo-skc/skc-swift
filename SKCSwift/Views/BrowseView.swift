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

                switch focusedResource {
                case .card:
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            ForEach(cardBrowseViewModel.cards, id: \.self.cardID) { card in
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
                    }
                    .toolbar {
                        Button {
                            cardBrowseViewModel.showFilters.toggle()
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease")
                        }
                        .sheet(isPresented: $cardBrowseViewModel.showFilters, onDismiss: {cardBrowseViewModel.showFilters = false}) {
                            if let filters = Binding<CardFilters>($cardBrowseViewModel.filters) {
                                CardFiltersView(filters: filters)
                            }
                        }
                    }
                case .product:
                    VStack {
                        ProductBrowseView(productsByYear: productBrowseViewModel.productsByYear)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .toolbar {
                        Button {
                            productBrowseViewModel.showFilters.toggle()
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease")
                        }
                        .sheet(isPresented: $productBrowseViewModel.showFilters, onDismiss: {productBrowseViewModel.showFilters = false}) {
                            ProductFiltersView(
                                productTypeFilters: $productBrowseViewModel.productTypeFilters,
                                productSubTypeFilters: $productBrowseViewModel.productSubTypeFilters)
                        }
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
        .task(priority: .userInitiated) {
            await productBrowseViewModel.fetchProductBrowseData()
        }
        .task(priority: .userInitiated) {
            await cardBrowseViewModel.fetchCardBrowseCriteria()
        }
    }
}

private struct HeaderView: View {
    let header: String

    var body: some View {
        HStack {
            Text(header)
                .font(.headline)
                .fontWeight(.black)
            Spacer()
        }
        .padding(.all, 5)
        .background(.thinMaterial)
        .cornerRadius(5)
    }
}

private struct ProductBrowseView: View {
    let productsByYear: [String: [Product]]?

    var body: some View {
        if let productsByYear = productsByYear, productsByYear.isEmpty {
            ContentUnavailableView("No filters selected - what were you expecting to see 🤔", systemImage: "exclamationmark.square.fill")
        } else if let productsByYear = productsByYear, !productsByYear.isEmpty {
            ScrollView {
                LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                    ForEach(productsByYear.keys.sorted(by: >), id: \.self) { year in
                        if let productForYear = productsByYear[year] {
                            Section(header: HeaderView(header: "\(year) • \(productForYear.count) total")) {
                                LazyVStack {
                                    ForEach(productForYear, id: \.productId) { product in
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
        } else {
            ProgressView()
        }
    }
}

private struct ProductFiltersView: View {
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

            ProductFilterView(filters: $productTypeFilters,
                              filterInfo: "Narrow down products",
                              filterImage: "1.circle",
                              columns: ProductFiltersView.productTypeColumns)
            ProductFilterView(filters: $productSubTypeFilters,
                              filterInfo: "Choose specific product category",
                              filterImage: "2.circle",
                              columns: ProductFiltersView.productSubTypeColumns)
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

struct CardFilterView<Content: View>: View {
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

#Preview {
    BrowseView()
}
