//
//  RelatedContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/24/23.
//

import SwiftUI

struct RelatedContentView: View {
    let cardID: String
    let cardName: String
    let cardColor: String
    let products:[Product]
    let tcgBanLists: [BanList]
    let mdBanLists: [BanList]
    
    init(cardID: String, cardName: String, cardColor: String, products: [Product], tcgBanLists: [BanList], mdBanLists: [BanList]) {
        self.cardID = cardID
        self.cardName = cardName
        self.cardColor = cardColor
        self.products = products
        self.tcgBanLists = tcgBanLists
        self.mdBanLists = mdBanLists
    }
    
    var body: some View {
        SectionView(header: "Explore",
                    variant: .plain,
                    content: {
            HStack(alignment: .top, spacing: 15) {
                VStack(alignment: .leading) {
                    Text("Products")
                        .font(.headline)
                    
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
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Ban Lists")
                        .font(.headline)
                    
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
