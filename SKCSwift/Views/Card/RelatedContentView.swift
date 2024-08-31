//
//  RelatedContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/24/23.
//

import SwiftUI

struct RelatedContentView: View {
    let cardName: String
    let cardColor: String
    let products:[Product]
    let tcgBanLists: [BanList]
    let mdBanLists: [BanList]
    let dlBanLists: [BanList]
    
    private let latestReleaseInfo: String
    
    init(cardName: String, cardColor: String, products: [Product], tcgBanLists: [BanList], mdBanLists: [BanList], dlBanLists: [BanList]) {
        self.cardName = cardName
        self.cardColor = cardColor
        self.products = products
        self.tcgBanLists = tcgBanLists
        self.mdBanLists = mdBanLists
        self.dlBanLists = dlBanLists
        
        if (!products.isEmpty) {
            let elapsedDays = products[0].productReleaseDate.timeIntervalSinceNow()
            if (products[0].productReleaseDate.timeIntervalSinceNow() < 0) {
                latestReleaseInfo = "\(elapsedDays.decimal) day(s) until next printing"
            } else {
                latestReleaseInfo = "\(elapsedDays.decimal) day(s) since last printing"
            }
        } else {
            latestReleaseInfo = "Last day printed not found in database"
        }
    }
    
    var body: some View {
        SectionView(header: "Explore",
                    variant: .plain,
                    content: {
            HStack(alignment: .top, spacing: 15) {
                VStack {
                    Text("Products")
                        .font(.headline)
                    
                    RelatedContentSheetButton(format: "TCG", contentCount: products.count, contentType: .products) {
                        RelatedContentsView(header: "Printings: \(products.count)",
                                            subHeader: "\(cardName) was printed in...") {
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
                    
                    Label(latestReleaseInfo, systemImage: "calendar")
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .padding(.top)
                }
                .tint(cardColorUI(cardColor: cardColor.replacing("Pendulum-", with: "")))
                
                Divider()
                
                VStack {
                    Text("Ban Lists")
                        .font(.headline)
                    
                    // TCG ban list deets
                    RelatedContentSheetButton(format: "TCG", contentCount: tcgBanLists.count, contentType: .banLists) {
                        RelatedContentsView(header: "Occurrences: \(tcgBanLists.count)",
                                            subHeader: "\(BanListFormat.tcg.rawValue) ban lists \(cardName) was restricted in...") {
                            BanListItemViewModel(banList: tcgBanLists)
                        }
                    }
                    
                    // MD ban list deets
                    RelatedContentSheetButton(format: "Master Duel", contentCount: mdBanLists.count, contentType: .banLists) {
                        RelatedContentsView(header: "Occurrences: \(mdBanLists.count)",
                                            subHeader: "\(BanListFormat.md.rawValue) ban lists \(cardName) was restricted in...") {
                            BanListItemViewModel(banList: mdBanLists)
                        }
                    }
                    
                    // DL ban list deets
                    RelatedContentSheetButton(format: "Duel Links", contentCount: dlBanLists.count, contentType: .banLists) {
                        RelatedContentsView(header: "Occurrences: \(dlBanLists.count)",
                                            subHeader: "\(BanListFormat.dl.rawValue) ban lists \(cardName) was restricted in...") {
                            BanListItemViewModel(banList: dlBanLists)
                        }
                    }
                }
                .tint(cardColorUI(cardColor: cardColor.replacing("Pendulum-", with: "")))
            }
        })
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
    @ViewBuilder let content: () -> Content
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(header)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .padding(.top)
                    Text(subHeader)
                        .font(.headline)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                })
            }
            .padding(.horizontal)
            
            ScrollView {
                content()
                    .frame(maxWidth: .infinity)
                    .modifier(ParentViewModifier())
            }
        }
    }
}

private struct BanListItemViewModel: View {
    let banList: [BanList]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
            ForEach(banList, id: \.banListDate) { banListInstance in
                GroupBox {
                    VStack {
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
                    }
                    .frame(maxWidth: .infinity)
                }
                .groupBoxStyle(.listItem)
            }
        }
    }
}
