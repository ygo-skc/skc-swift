//
//  BrowseView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/11/24.
//

import SwiftUI

struct BrowseView: View {
    @State private var path = NavigationPath()
    @State private var focusedResource = TrendingResourceType.card
    
    @State private var productBrowseViewModel = ProductBrowseViewModel()
    @State private var cardBrowseViewModel = CardBrowseViewModel()
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack {
                    Picker("Select resource to browse", selection: $focusedResource) {
                        ForEach(TrendingResourceType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    switch (focusedResource) {
                    case .card:
                        CardBrowseView(path: $path, filteredCards: cardBrowseViewModel.cards)
                            .task(priority: .userInitiated) {
                                await cardBrowseViewModel.fetchCardBrowseCriteria()
                            }
                    case .product:
                        ProductBrowseView(path: $path, filteredProducts: productBrowseViewModel.filteredProducts)
                            .task(priority: .userInitiated) {
                                await productBrowseViewModel.fetchProductBrowseData()
                            }
                    }
                }
                .modifier(.parentView)
            }
            .toolbar {
                switch focusedResource {
                case .card:
                    FilterButton(showFilters: $cardBrowseViewModel.showFilters) {
                        if cardBrowseViewModel.criteriaError == nil {
                            CardFiltersView(filters: $cardBrowseViewModel.filters)
                        }
                    }
                    .if(cardBrowseViewModel.criteriaError != nil ) {
                        $0.hidden()
                    }
                case .product:
                    FilterButton(showFilters: $productBrowseViewModel.showFilters) {
                        ProductFiltersView(
                            productTypeFilters: $productBrowseViewModel.productTypeFilters,
                            productSubTypeFilters: $productBrowseViewModel.productSubTypeFilters)
                    }
                    .if(productBrowseViewModel.dataError != nil ) {
                        $0.hidden()
                    }
                }
            }
            .ygoNavigationDestination()
            .navigationTitle("Browse")
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
            .overlay {
                switch focusedResource {
                case .card:
                    CardBrowseOverlay(criteriaRequestStatus: cardBrowseViewModel.criteriaStatus,
                                      noCardsFound: cardBrowseViewModel.cards.isEmpty && cardBrowseViewModel.criteriaError == nil
                                      && cardBrowseViewModel.dataError == nil,
                                      criteriaRequestError: cardBrowseViewModel.criteriaError, dataRequestError: cardBrowseViewModel.dataError,
                                      retryCriteriaRequest: cardBrowseViewModel.fetchCardBrowseCriteria, retryDataRequest: cardBrowseViewModel.fetchCards)
                case .product:
                    ProductBrowseOverlay(dataRequestStatus: productBrowseViewModel.dataStatus,
                                         dataRequestError: productBrowseViewModel.dataError,
                                         retryDataRequest: productBrowseViewModel.fetchProductBrowseData)
                }
            }
        }
    }
}

private struct CardBrowseOverlay: View {
    let criteriaRequestStatus: DataTaskStatus
    let noCardsFound: Bool
    let criteriaRequestError: NetworkError?
    let dataRequestError: NetworkError?
    let retryCriteriaRequest: () async -> Void
    let retryDataRequest: () async -> Void
    
    var body: some View {
        switch criteriaRequestStatus {
        case .pending, .uninitiated:
            ProgressView("Loading...")
                .controlSize(.large)
        case .done where noCardsFound:
            ContentUnavailableView("No cards found using the selected filters 😕", systemImage: "exclamationmark.square.fill")
        case .done:
            if let networkError = criteriaRequestError {
                NetworkErrorView(error: networkError, action: { Task{ await retryCriteriaRequest() } })
            } else if let networkError = dataRequestError {
                NetworkErrorView(error: networkError, action: { Task{ await retryDataRequest() } })
            }
        }
    }
}

private struct ProductBrowseOverlay: View {
    let dataRequestStatus: DataTaskStatus
    let dataRequestError: NetworkError?
    let retryDataRequest: () async -> Void
    
    var body: some View {
        switch dataRequestStatus {
        case .pending, .uninitiated:
            ProgressView("Loading...")
                .controlSize(.large)
        case .done:
            if let networkError = dataRequestError {
                NetworkErrorView(error: networkError, action: { Task{ await retryDataRequest() } })
            }
        }
    }
}

private struct ProductBrowseView: View {
    @Binding var path: NavigationPath
    let filteredProducts: [String: [Product]]
    
    var body: some View {
        LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
            ForEach(filteredProducts.keys.sorted(by: >), id: \.self) { year in
                if let filteredProducts = filteredProducts[year] {
                    Section(header: HeaderView(header: "\(year) • \(filteredProducts.count) total")) {
                        LazyVStack {
                            ForEach(filteredProducts, id: \.productId) { product in
                                Button {
                                    path.append(ProductLinkDestinationValue(productID: product.productId, productName: product.productName))
                                } label: {
                                    GroupBox {
                                        ProductListItemView(product: product)
                                            .equatable()
                                    }
                                    .groupBoxStyle(.listItem)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .ignoresSafeArea(.keyboard)
        }
    }
}

private struct CardBrowseView: View {
    @Binding var path: NavigationPath
    let filteredCards: [Card]
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            ForEach(filteredCards, id: \.self.cardID) { card in
                Button {
                    path.append(CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName))
                } label: {
                    GroupBox {
                        CardListItemView(card: card, showAllInfo: true)
                            .equatable()
                    }
                    .groupBoxStyle(.listItem)
                }
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
            .ignoresSafeArea(.keyboard)
        }
    }
}

private struct ProductFiltersView: View {
    @Binding var productTypeFilters: [FilteredItem<String>]
    @Binding var productSubTypeFilters: [FilteredItem<String>]
    
    var body: some View {
        VStack {
            Text("Product filters")
                .font(.title)
            Text("Filter products by type or sub-type, by default every filter is enabled - try disabling some to tune to your liking 😉")
                .font(.callout)
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
        .modifier(.parentView)
        .padding(.top)
    }
}

private struct ProductFilterView: View {
    @Binding var filters: [FilteredItem<String>]
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
        ScrollView {
            VStack {
                Text("Card filters")
                    .font(.title)
                Text("Filter cards by using card metadata")
                    .font(.callout)
                    .padding(.bottom)
                
                CardFilterView(filters: $filters.attributes, filterInfo: "Filter by attribute") { attribute in
                    AttributeView(attribute: Attribute(rawValue: attribute) ?? .unknown)
                }
                CardFilterView(filters: $filters.colors, filterInfo: "Filter by card color") { category in
                    CardColorIndicatorView(cardColor: category, variant: .large)
                }
                CardFilterView(filters: $filters.monsterTypes, filterInfo: "Filter by monster type") { monsterType in
                    MonsterTypeView(monsterType: monsterType, variant: .large)
                }
                CardFilterView(filters: $filters.levels, filterInfo: "Filter by monster level", gridItemCount: 4) { level in
                    LevelAssociationView(level: level, variant: .regular)
                }
                CardFilterView(filters: $filters.ranks, filterInfo: "Filter by monster rank", gridItemCount: 4) { rank in
                    RankAssociationView(rank: rank, variant: .regular)
                }
                CardFilterView(filters: $filters.linkRatings, filterInfo: "Filter by monster link rating", gridItemCount: 6) { linkRating in
                    Text("\(linkRating)")
                        .font(.headline)
                        .fontWeight(.heavy)
                }
            }
            .modifier(.parentView)
        }
    }
}

private struct CardFilterView<T: Equatable & Sendable, Content: View>: View {
    @Binding var filters: [FilteredItem<T>]
    let filterInfo: String
    let gridItemCount: Int
    @ViewBuilder let content: (T) -> Content
    
    init(filters: Binding<[FilteredItem<T>]>, filterInfo: String, gridItemCount: Int, content: @escaping (T) -> Content) {
        self._filters = filters
        self.filterInfo = filterInfo
        self.gridItemCount = gridItemCount
        self.content = content
    }
    
    var body: some View {
        GroupBox {
            GroupBox {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: gridItemCount)) {
                    ForEach($filters) { $cardColorFilter in
                        Toggle(isOn: $cardColorFilter.isToggled) {
                            content(cardColorFilter.category)
                                .frame(maxWidth: .infinity)
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

extension CardFilterView {
    init(filters: Binding<[FilteredItem<T>]>, filterInfo: String, content: @escaping (T) -> Content) {
        self.init(filters: filters, filterInfo: filterInfo, gridItemCount: 6, content: content)
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
