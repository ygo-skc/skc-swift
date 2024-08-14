//
//  RelatedContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/24/23.
//

import SwiftUI

protocol RelatedContent: View {}

struct RelatedContentView: View {
    var cardName: String
    var products:[Product]
    var tcgBanLists: [BanList]
    var mdBanLists: [BanList]
    var dlBanLists: [BanList]
    
    var body: some View {
        SectionView(header: "Explore",
                    variant: .plain,
                    content: {
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .top, spacing: 15) {
                    RelatedProductsSectionViewModel(cardName: cardName, products: products)
                    Divider()
                    RelatedBanListsSectionViewModel(cardName: cardName, tcgBanLists: tcgBanLists, mdBanLists: mdBanLists, dlBanLists: dlBanLists)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
        }
        )
    }
}

private struct RelatedContentSectionHeaderViewModel: View {
    let header: String
    
    var body: some View {
        Text(header)
            .font(.headline)
    }
}

private struct RelatedProductsSectionViewModel: RelatedContent {
    var cardName: String
    var products: [Product]
    
    private var latestReleaseInfo = "Last Day Printed Not Found In DB"
    
    init(cardName: String, products: [Product]) {
        self.cardName = cardName
        self.products = products
        
        if (!products.isEmpty) {
            let elapsedDays = products[0].productReleaseDate.timeIntervalSinceNow()
            
            if (elapsedDays < 0) {
                latestReleaseInfo = "\(elapsedDays.decimal) day(s) until next printing"
            } else {
                latestReleaseInfo = "\(elapsedDays.decimal) day(s) since last printing"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            RelatedContentSectionHeaderViewModel(header: "Products")
            
            RelatedContentSheetButton(format: "TCG", contentCount: products.count, contentType: .products) {
                RelatedProductsContentView(cardName: cardName, products: self.products)
            }
            
            Label(latestReleaseInfo, systemImage: "calendar")
                .font(.subheadline)
                .fontWeight(.light)
                .padding(.top)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct RelatedBanListsSectionViewModel: RelatedContent{
    var cardName: String
    var tcgBanLists: [BanList]
    var mdBanLists: [BanList]
    var dlBanLists: [BanList]
    
    var body: some View {
        VStack(spacing: 8) {
            RelatedContentSectionHeaderViewModel(header: "Ban Lists")
            
            // TCG ban list deets
            RelatedContentSheetButton(format: "TCG", contentCount: tcgBanLists.count, contentType: .ban_lists) {
                RelatedBanListsContentView(cardName: cardName, banlists: tcgBanLists, format: BanListFormat.tcg)
            }
            
            // MD ban list deets
            RelatedContentSheetButton(format: "Master Duel", contentCount: mdBanLists.count, contentType: .ban_lists) {
                RelatedBanListsContentView(cardName: cardName, banlists: mdBanLists, format: BanListFormat.md)
            }
            
            // DL ban list deets
            RelatedContentSheetButton(format: "Duel Links", contentCount: dlBanLists.count, contentType: .ban_lists) {
                RelatedBanListsContentView(cardName: cardName, banlists: dlBanLists, format: BanListFormat.dl)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct RelatedContentSheetButton<RC: RelatedContent>: View {
    let format: String
    let contentCount: Int
    var contentType: RelatedContentType
    let sheetContent: RC
    
    init(format: String, contentCount: Int, contentType: RelatedContentType, @ViewBuilder sheetContent: () -> RC) {
        self.format = format
        self.contentCount = contentCount
        self.contentType = contentType
        self.sheetContent = sheetContent()
    }
    
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
            sheetContent
        }
        .disabled(contentCount <= 0)
    }
}

#Preview("Stratos") {
    RelatedContentView(cardName: "Elemental HERO Stratos",
                       products: [
                        Product(productId: "HAC1", productLocale: "EN", productName: "Hidden Arsenal: Chapter 1", productType: "Set", productSubType: "Collector", productReleaseDate: "2022-03-11",
                                productContent: [
                                    ProductContent(productPosition: "015", rarities: ["Duel Terminal Normal Parallel Rare", "Common"])
                                ]
                               )
                       ],
                       tcgBanLists: [
                        BanList(banListDate: "2019-07-15", cardID: "40044918", banStatus: "Semi-Limited", format: "TCG"),
                        BanList(banListDate: "2019-04-29", cardID: "40044918", banStatus: "Limited", format: "TCG"),
                        BanList(banListDate: "2019-01-28", cardID: "40044918", banStatus: "Limited", format: "TCG")
                       ],
                       mdBanLists: [],
                       dlBanLists: []
    )
}

#Preview("Liquid Boi") {
    RelatedContentView(cardName: "Elemental HERO Liquid Soldier",
                       products: [
                        Product(productId: "LDS3", productLocale: "EN", productName: "Legendary Duelists: Season 3", productType: "Set", productSubType: "Reprint", productReleaseDate: "2022-07-22",
                                productContent: [
                                    ProductContent(productPosition: "103", rarities: ["Secret Rare"])
                                ]
                               ),
                        Product(productId: "LED6", productLocale: "EN", productName: "Legendary Duelists: Magical Hero", productType: "Pack", productSubType: "Legendary Duelists", productReleaseDate: "2020-01-17",
                                productContent: [
                                    ProductContent(productPosition: "013", rarities: ["Ultra Rare"])
                                ]
                               )
                       ],
                       tcgBanLists: [],
                       mdBanLists: [],
                       dlBanLists: [
                        BanList(banListDate: "2022-12-26", cardID: "59392529", banStatus: "Limited 2", format: "DL"),
                        BanList(banListDate: "2022-12-08", cardID: "59392529", banStatus: "Limited 2", format: "DL"),
                        BanList(banListDate: "2022-09-28", cardID: "59392529", banStatus: "Limited 2", format: "DL")
                       ]
    )
}

#Preview("Monster Reborn") {
    RelatedContentView(cardName: "Monster Reborn",
                       products: [],
                       tcgBanLists: [
                        BanList(banListDate: "2022-12-01", cardID: "83764718", banStatus: "Limited", format: "TCG"),
                        BanList(banListDate: "2022-10-03", cardID: "83764718", banStatus: "Limited", format: "TCG")
                       ],
                       mdBanLists: [
                        BanList(banListDate: "2023-01-10", cardID: "83764718", banStatus: "Limited", format: "MD")
                       ],
                       dlBanLists: [
                        BanList(banListDate: "2022-12-26", cardID: "83764718", banStatus: "Limited 1", format: "DL"),
                        BanList(banListDate: "2022-12-08", cardID: "83764718", banStatus: "Limited 1", format: "DL"),
                        BanList(banListDate: "2022-09-28", cardID: "83764718", banStatus: "Limited 1", format: "DL")
                       ]
    )
}
