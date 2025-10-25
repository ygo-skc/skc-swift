//
//  BannedContent.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/10/23.
//

import SwiftUI

struct BanListContentView: View {
    @State private var mainSheetContentHeight: CGFloat = 0
    @State private var path = NavigationPath()
    @State private var model = RestrictedCardsViewModel()
    
    var body: some View {
        NavigationStack(path: $path) {
            SegmentedView(mainSheetContentHeight: $mainSheetContentHeight) {
                ScrollView {
                    SectionView(header: "Forbidden/Limited Content",
                                variant: .plain,
                                content: {
                        if let bannedContent = model.bannedContent {
                            switch model.chosenBannedContentCategory {
                            case .forbidden:
                                BannedContentView(path: $path, content: bannedContent.forbidden)
                            case .limited:
                                BannedContentView(path: $path, content: bannedContent.limited)
                            case .semiLimited:
                                BannedContentView(path: $path, content: bannedContent.semiLimited)
                            }
                        }
                    })
                    .modifier(.parentView)
                    .padding(.bottom, 0)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: mainSheetContentHeight)
                }
            } mainSheetContent: {
                BanListNavigatorView(format: $model.format, dateRangeIndex: $model.dateRangeIndex, contentCategory: $model.chosenBannedContentCategory, dates: model.banListDates)
            }
            .onChange(of: model.format, initial: true) {
                Task {
                    await model.fetchData(formatChanged: true)
                }
            }
            .onChange(of: model.dateRangeIndex, initial: true) {
                Task {
                    await model.fetchData()
                }
            }
            .ygoNavigationDestination()
        }
    }
}

private struct BannedContentView: View {
    @Binding var path: NavigationPath
    let content: [Card]
    
    var body: some View {
        LazyVStack {
            ForEach(content, id: \.self.cardID) { card in
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
    }
}

#Preview() {
    BanListContentView()
}
