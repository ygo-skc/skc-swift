//
//  RelatedContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/24/23.
//

import SwiftUI
import YGOService

struct CardReleasesView: View {
    let cardID: String
    let cardName: String
    let cardColor: String
    let products: [Product]
    let rarityDistribution: [String: Int]
    
    private let initialReleaseHeader: String
    private let initialReleaseSubHeader: String
    
    private let latestReleaseHeader: String?
    private let latestReleaseSubHeader: String?
    
    init(cardID: String, cardName: String, cardColor: String, products: [Product], rarityDistribution: [String : Int]) {
        self.cardID = cardID
        self.cardName = cardName
        self.cardColor = cardColor
        self.products = products
        self.rarityDistribution = rarityDistribution
        
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
                initialReleaseHeader = "\(elapsedDays.decimal) day(s)"
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
    
    var body: some View {
        SectionView(header: "Releases",
                    variant: .plain,
                    content: {
            VStack(alignment: .leading) {
                if !products.isEmpty {
                    Label("Rarities", systemImage: "star.square.on.square")
                        .font(.headline)
                    Text("All unique rarities \(cardName) was printed in")
                        .font(.callout)
                    OneDBarChartView(data: rarityDistribution.map { ChartData(category: $0.key, count: $0.value) } )
                        .padding(.bottom)
                }
                
                Label("Products", systemImage: "cart")
                    .font(.headline)
                    .padding(.bottom, 4)
                if !products.isEmpty {
                    RelatedContentSheetButton(format: "TCG", contentCount: products.count, contentType: .products) {
                        RelatedContentsView(header: "Products",
                                            subHeader: "\(cardName) was printed in \(products.count) different products.", cardID: cardID) {
                            LazyVStack {
                                ForEach(products, id: \.id) { product in
                                    GroupBox {
                                        ProductListItemView(product: product)
                                            .equatable()
                                    }
                                    .groupBoxStyle(.listItem)
                                }
                            }
                        }
                    }
                    .tint(cardColorUI(cardColor: cardColor.replacing("Pendulum-", with: "")))
                }
                
                HStack(spacing: 10) {
                    CardView {
                        Group {
                            Label(initialReleaseHeader, systemImage: products.isEmpty ? "exclamationmark.triangle" : "1.circle")
                                .font(.title3)
                                .padding(.bottom, 2)
                            Text(initialReleaseSubHeader)
                                .font(.subheadline)
                                .padding(.bottom, 2)
                        }
                    }
                    if let latestReleaseHeader, let latestReleaseSubHeader {
                        CardView {
                            Group {
                                Label(latestReleaseHeader, systemImage: "calendar")
                                    .font(.title3)
                                    .padding(.bottom, 2)
                                Text(latestReleaseSubHeader)
                                    .font(.subheadline)
                                    .padding(.bottom, 2)
                            }
                        }
                    }
                }
                .padding(.top)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        })
    }
}

struct CardRestrictionsView: View {
    let cardID: String
    let cardName: String
    let cardColor: String
    
    let score: CardScore
    let tcgBanLists: [BanList]
    let mdBanLists: [BanList]
    
    init(cardID: String, cardName: String, cardColor: String, score: CardScore, tcgBanLists: [BanList], mdBanLists: [BanList]) {
        self.cardID = cardID
        self.cardName = cardName
        self.cardColor = cardColor
        self.score = score
        self.tcgBanLists = tcgBanLists
        self.mdBanLists = mdBanLists
    }
    
    var body: some View {
        SectionView(header: "Restrictions",
                    variant: .plain,
                    content: {
            VStack(alignment: .leading) {
                Label("Summary", systemImage: "list.bullet.rectangle")
                    .font(.headline)
                    .padding(.bottom, 4)
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
        })
        .tint(cardColorUI(cardColor: cardColor.replacing("Pendulum-", with: "")))
    }
}

private struct RelatedContentSheetButton<Content: View>: View {
    let format: String
    let contentCount: Int
    let contentType: RelatedContentType
    @ViewBuilder let content: () -> Content
    
    @State private var showSheet = false
    
    var body: some View {
        Button {
            showSheet.toggle()
        } label: {
            VStack {
                Text(format)
                    .font(.subheadline)
                    .bold()
                Text("\(contentCount) ").font(.subheadline).fontWeight(.bold) + Text((contentType == .products) ? "Printings" : "Occurrences").font(.subheadline)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .sheet(isPresented: $showSheet, onDismiss: {showSheet = false}) {
            content()
        }
        .disabled(contentCount <= 0)
    }
}

private struct RelatedContentsView<Content: View>: View {
    let header: String
    let subHeader: String
    let cardID: String
    @ViewBuilder let content: () -> Content
    
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
                
                content()
            }
            .modifier(.parentView)
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
