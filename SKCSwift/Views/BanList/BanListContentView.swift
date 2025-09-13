//
//  BannedContent.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/10/23.
//

import SwiftUI

struct BanListContentView: View {
    @State private var path = NavigationPath()
    @State private var model = BannedContentViewModel()
    
    var body: some View {
        NavigationStack(path: $path) {
            SegmentedView {
                ScrollView {
                    if let bannedContent = model.bannedContent {
                        LazyVStack {
                            ForEach(bannedContent.forbidden, id: \.self.cardID) { card in
                                Button {
                                    path.append(CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName))
                                } label: {
                                    GroupBox {
                                        CardListItemView(card: card)
                                            .equatable()
                                    }
                                    .groupBoxStyle(.listItem)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .modifier(.parentView)
                    }
                }
            } sheetContent: {
                BanListNavigatorView(format: $model.format, dateRangeIndex: $model.dateRangeIndex, dates: model.banListDates)
            }
            .onChange(of: model.format, initial: true) {
                Task {
                    await model.fetchBanListDates()
                    await model.fetchBannedContent()
                }
            }
            .onChange(of: model.dateRangeIndex, initial: true) {
                Task {
                    await model.fetchBannedContent()
                }
            }
            .ygoNavigationDestination()
        }
    }
}

#Preview() {
    BanListContentView()
}
