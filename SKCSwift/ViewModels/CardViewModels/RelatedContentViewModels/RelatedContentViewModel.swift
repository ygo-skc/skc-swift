//
//  RelatedContentViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/24/23.
//

import SwiftUI

protocol RelatedContent: View {}

struct RelatedContentViewModel: View {
    var cardName: String
    var products:[Product]
    var tcgBanLists: [BanList]
    var mdBanLists: [BanList]
    var dlBanLists: [BanList]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Related Content")
                .font(.title)
            Text("Expore Yu-Gi-Oh! products or forbidden/ban lists that are assoicated with this card")
                .font(.headline)
                .fontWeight(.light)
                .padding(.top, -10)
            
            HStack(alignment: .top, spacing: 10) {
                RelatedProductsSectionViewModel(cardName: cardName, products: products)
                RelatedBanListsSectionViewModel(cardName: cardName, tcgBanLists: tcgBanLists, mdBanLists: mdBanLists, dlBanLists: dlBanLists)
            }
            .padding(.top)
            .frame(maxWidth: .infinity)
        }
        .padding(.all)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

private struct RelatedContentSectionHeaderViewModel: View {
    var header: String
    
    var body: some View {
        Text(header)
            .font(.title2)
            .fontWeight(.black)
    }
}

private struct RelatedProductsSectionViewModel: RelatedContent {
    var cardName: String
    var products: [Product]
    
    private var latestReleaseInfo = "Last Day Printed Not Found In DB"
    
    init(cardName: String, products: [Product]) {
        self.cardName = cardName
        self.products = products
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if (!products.isEmpty) {
            let elapsedDays = determineElapsedDaysSinceToday(reference: products[0].productReleaseDate)
            
            if (elapsedDays > 0) {
                latestReleaseInfo = "\(elapsedDays) day(s) until next printing"
            } else {
                latestReleaseInfo = "\(elapsedDays) day(s) since last printing"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            RelatedContentSectionHeaderViewModel(header: "Products")
            
            RelatedContentSheetButton(text: "TCG") {
                RelatedProductsContentViewModels(cardName: cardName, products: self.products)
            }
            .disabled(products.isEmpty)
            
            HStack {
                Text(String(products.count))
                    .font(.body)
                    .fontWeight(.bold)
                Text("Printing(s)")
                    .font(.body)
                    .fontWeight(.light)
                    .padding(.leading, -5)
            }
            
            HStack {
                Image(systemName: "calendar")
                Text(latestReleaseInfo)
                    .font(.subheadline)
                    .fontWeight(.light)
                    .padding(.top, 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private struct RelatedBanListsSectionViewModel: RelatedContent{
    var cardName: String
    var tcgBanLists: [BanList]
    var mdBanLists: [BanList]
    var dlBanLists: [BanList]
    
    var body: some View {
        VStack(alignment: .leading) {
            RelatedContentSectionHeaderViewModel(header: "Ban Lists")
            
            // TCG ban list deets
            RelatedContentSheetButton(text: "TCG") {
                RelatedBanListsContentViewModel(cardName: cardName, banlists: tcgBanLists, format: BanListFormat.tcg)
            }
            .disabled(tcgBanLists.isEmpty)
            RelatedBanListsOccurrences(occurrences: tcgBanLists.count)
            
            Divider()
            
            // MD ban list deets
            RelatedContentSheetButton(text: "Master Duel") {
                RelatedBanListsContentViewModel(cardName: cardName, banlists: mdBanLists, format: BanListFormat.md)
            }
            .disabled(mdBanLists.isEmpty)
            RelatedBanListsOccurrences(occurrences: mdBanLists.count)
            
            Divider()
            
            // DL ban list deets
            RelatedContentSheetButton(text: "Duel Links") {
                RelatedBanListsContentViewModel(cardName: cardName, banlists: dlBanLists, format: BanListFormat.dl)
            }
            .disabled(dlBanLists.isEmpty)
            RelatedBanListsOccurrences(occurrences: dlBanLists.count)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private struct RelatedBanListsOccurrences: View {
    var occurrences: Int
    
    var body: some View {
        HStack {
            Text(String(occurrences))
                .font(.body)
                .fontWeight(.bold)
            Text("Occurences(s)")
                .font(.body)
                .fontWeight(.light)
                .padding(.leading, -5)
        }
    }
}

private struct RelatedContentSheetButton<RC: RelatedContent>: View {
    var text: String
    var sheetContent: RC
    
    init(text: String, @ViewBuilder sheetContent: () -> RC) {
        self.text = text
        self.sheetContent = sheetContent()
    }
    
    @State private var showSheet = false
    
    var body: some View {
        Button {
            showSheet.toggle()
        } label: {
            HStack {
                Text(text)
                    .font(.headline)
                Image(systemName: "chevron.right")
            }
        }
        .sheet(isPresented: $showSheet, onDismiss: {showSheet = false}) {
            sheetContent
        }
        .padding([.top, .bottom], 1)
    }
}

struct RelatedContentViewModel_Previews: PreviewProvider {
    static var previews: some View {
        RelatedContentViewModel(cardName: "Elemental HERO Stratos",
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
        .previewDisplayName("Stratos")
        
        RelatedContentViewModel(cardName: "Elemental HERO Liquid Soldier",
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
        .previewDisplayName("Liquid Boi")
        
        RelatedContentViewModel(cardName: "Monster Reborn",
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
        .previewDisplayName("Liquid Boi")
    }
}
