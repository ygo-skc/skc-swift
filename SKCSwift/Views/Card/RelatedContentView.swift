//
//  RelatedContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/24/23.
//

import SwiftUI

struct CardReleasesView: View {
    @Binding private var path: NavigationPath
    private let cardID: String
    private let cardName: String
    private let cardColor: String
    private let products: [Product]
    private let rarityDistribution: [String: Int]
    
    private let initialReleaseHeader: String
    private let initialReleaseSubHeader: String
    
    private let latestReleaseHeader: String?
    private let latestReleaseSubHeader: String?
    
    private static let MAX_RELEASES_TO_SHOW: Int = 5
    
    init(path: Binding<NavigationPath>, card: YGOCard, products: [Product]) {
        self._path = path
        self.cardID = card.cardID
        self.cardName = card.cardName
        self.cardColor = card.cardColor
        self.products = products
        self.rarityDistribution = products.rarityDistribution()
        
        if !products.isEmpty {
            if products.count > 1 {
                let elapsedDays = products[0].productReleaseDate.timeIntervalSinceNow()
                if elapsedDays < 0 {
                    latestReleaseHeader = "\(elapsedDays.decimal) day(s)"
                    latestReleaseSubHeader = "Until next printing"
                } else {
                    latestReleaseHeader = "\(elapsedDays.decimal) day(s)"
                    latestReleaseSubHeader = "Since last printing"
                }
            } else {
                (latestReleaseHeader, latestReleaseSubHeader) = (nil, nil)
            }
            
            let elapsedDays = products.last!.productReleaseDate.timeIntervalSinceNow()
            if elapsedDays < 0 {
                initialReleaseHeader = "\(abs(elapsedDays).decimal) day(s)"
                initialReleaseSubHeader = "From card debuts"
            } else {
                initialReleaseHeader = "\(elapsedDays.decimal) day(s)"
                initialReleaseSubHeader = "Since initial printing"
            }
        } else {
            initialReleaseHeader = "No printings"
            initialReleaseSubHeader = "No product data"
            
            (latestReleaseHeader, latestReleaseSubHeader) = (nil, nil)
        }
    }
    
    @ViewBuilder
    private var rarities: some View {
        Label("Rarities", systemImage: "star.square.on.square")
            .font(.headline)
            .padding(.bottom, 5)
        Text("All unique rarities \(cardName) was printed in")
            .font(.callout)
        OneDBarChartView(data: rarityDistribution.map { ChartData(category: $0.key, count: $0.value) } )
    }
    
    @ViewBuilder
    private var printedIn: some View {
        if products.count > CardReleasesView.MAX_RELEASES_TO_SHOW {
            SummaryBarLink("Printed In • \(products.count)",
                           systemImage: "cart",
                           value: ProductListLinkDestinationValue(products: products))
        } else {
            Label("Printed In • \(products.count)", systemImage: "cart")
                .font(.headline)
        }
        
        ForEach(Array(products).prefix(CardReleasesView.MAX_RELEASES_TO_SHOW), id: \.id) { product in
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
            .transition(.opacity)
        }
    }
    
    @ViewBuilder
    private var releaseSummary: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                CardView {
                    Group {
                        Label(initialReleaseHeader, systemImage: products.isEmpty ? "exclamationmark.triangle" : "1.circle")
                            .font(.title3)
                        Text(initialReleaseSubHeader)
                            .font(.subheadline)
                    }
                }
                if let latestReleaseHeader, let latestReleaseSubHeader {
                    CardView {
                        Group {
                            Label(latestReleaseHeader, systemImage: "calendar")
                                .font(.title3)
                            Text(latestReleaseSubHeader)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .padding(.bottom, 10)
        }
        .padding(.top)
        .scrollIndicators(.hidden)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Releases")
                .headerTextModifier()
            if products.isEmpty {
                ContentUnavailableView(initialReleaseSubHeader, systemImage: "tray.fill")
            } else {
                rarities
                Divider()
                    .padding(.vertical)
                printedIn
                releaseSummary
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct ProductListView: View {
    @Binding var path: NavigationPath
    let values: ProductListLinkDestinationValue
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(values.products, id: \.id) { product in
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
                    .transition(.opacity)
                }
            }
            .parentModifier()
            .navigationTitle("Products")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct CardRestrictionsView: View {
    let cardID: String
    let cardName: String
    let cardColor: String
    
    let score: CardScore?
    let tcgBanLists: [BanList]
    let mdBanLists: [BanList]
    
    init(card: YGOCard, tcgBanList: [BanList], mdBanLists: [BanList], score: CardScore?) {
        self.cardID = card.cardID
        self.cardName = card.cardName
        self.cardColor = card.cardColor
        self.score = score
        self.tcgBanLists = tcgBanList
        self.mdBanLists =  mdBanLists
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Restrictions")
                .headerTextModifier()
            if let score {
                Label("Summary", systemImage: "list.bullet.rectangle")
                    .font(.headline)
                    .padding(.bottom, 5)
                Text("Current restrictions on \(cardName)")
                    .font(.callout)
                
                ForEach(score.uniqueFormats, id: \.self) { format in
                    if let cardScore = score.currentScoreByFormat[format] {
                        CardView {
                            Group {
                                Label("\(cardScore) points", systemImage: "medal.star.fill")
                                    .font(.title3)
                                    .padding(.bottom, 2)
                                Text("\(format) format")
                                    .font(.subheadline)
                                    .padding(.bottom, 2)
                            }
                        }
                    }
                }
            }
            
            Divider()
                .padding(.vertical)
            
            Label("Historical", systemImage: "hourglass.circle")
                .font(.headline)
                .padding(.vertical, 4)
            // TCG ban list deets
            RelatedContentSheetButton(format: "TCG", contentCount: tcgBanLists.count, contentType: .banLists) {
                RelatedContentsView(header: "TCG F/L Hits",
                                    subHeader: "\(cardName) was restricted at least \(tcgBanLists.count) times in the TCG format.", cardID: cardID) {
                    BanListItemViewModel(banList: tcgBanLists)
                }
            }
            
            // MD ban list deets
            RelatedContentSheetButton(format: "Master Duel", contentCount: mdBanLists.count, contentType: .banLists) {
                RelatedContentsView(header: "Master Duel F/L Hits",
                                    subHeader: "\(cardName) was restricted at least \(mdBanLists.count) times in the Master Duel format.", cardID: cardID) {
                    BanListItemViewModel(banList: mdBanLists)
                }
            }
        }
        .tint(cardColorUI(cardColor: cardColor.replacing("Pendulum-", with: "")))
    }
}

private struct RelatedContentSheetButton<Content: View>: View {
    let format: String
    let contentCount: Int
    let contentType: RelatedContentType
    let content: Content
    
    @State private var showSheet = false
    
    init(format: String,
         contentCount: Int,
         contentType: RelatedContentType,
         @ViewBuilder content: () -> Content,
         showSheet: Bool = false) {
        self.format = format
        self.contentCount = contentCount
        self.contentType = contentType
        self.content = content()
        self.showSheet = showSheet
    }
    
    var body: some View {
        Button {
            showSheet.toggle()
        } label: {
            VStack {
                Text(format)
                    .font(.subheadline)
                    .bold()
                HStack(spacing: 2) {
                    Text("\(contentCount) ").font(.subheadline).fontWeight(.bold)
                    Text((contentType == .products) ? "Printings" : "Occurrences").font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .sheet(isPresented: $showSheet, onDismiss: {showSheet = false}) {
            content
        }
        .disabled(contentCount <= 0)
    }
}

private struct RelatedContentsView<Content: View>: View {
    let header: String
    let subHeader: String
    let cardID: String
    let content: Content
    
    init(header: String,
         subHeader: String,
         cardID: String,
         @ViewBuilder content: () -> Content) {
        self.header = header
        self.subHeader = subHeader
        self.cardID = cardID
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Label {
                    Text(header)
                        .font(.title)
                } icon: {
                    CardImageView(length: 50, cardID: cardID, imgSize: .tiny)
                }
                Text(subHeader)
                    .font(.callout)
                    .padding(.bottom)
                
                content
            }
            .sheetParentModifier()
        }
    }
}

private struct BanListItemViewModel: View {
    let banList: [BanList]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
            ForEach(banList, id: \.banListDate) { banListInstance in
                GroupBox {
                    VStack(alignment: .leading) {
                        DateBadgeView(date: banListInstance.banListDate, variant: .condensed)
                            .equatable()
                        HStack {
                            Circle()
                                .foregroundColor(banStatusColor(status: banListInstance.banStatus))
                                .frame(width: 18)
                            Text(banListInstance.banStatus)
                                .lineLimit(1)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                }
                .groupBoxStyle(.listItem)
            }
        }
    }
}
