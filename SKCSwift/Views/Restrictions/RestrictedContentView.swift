//
//  RestrictedContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/10/23.
//

import SwiftUI

struct RestrictedContentView: View {
    @State private var mainSheetContentHeight: CGFloat = 0
    @State private var path = NavigationPath()
    @State private var model = RestrictedCardsViewModel()
    
    var body: some View {
        NavigationStack(path: $path) {
            SegmentedView(mainSheetContentHeight: $mainSheetContentHeight) {
                ScrollView {
                    SectionView(header: "\(model.format.rawValue) Content",
                                variant: .plain,
                                content: {
                        if ![DataTaskStatus.uninitiated, DataTaskStatus.pending].contains(model.dataTaskStatuses[.content]) {
                            switch model.format {
                            case .md, .tcg:
                                if let restrictedCards = model.restrictedCards {
                                    BannedContentView(path: $path, content: restrictedCards)
                                }
                            case .genesys:
                                if let scoreEntries = model.scoreEntries {
                                    CardScoresView(path: $path, content: scoreEntries)
                                }
                            }
                        }
                    })
                    .modifier(.parentView)
                    .padding(.bottom, 0)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: mainSheetContentHeight)
                }
                .overlay {
                    if [DataTaskStatus.uninitiated, DataTaskStatus.pending].contains(model.dataTaskStatuses[.content]) {
                        ProgressView("Loading...")
                            .controlSize(.large)
                    }
                }
            } mainSheetContent: {
                BanListNavigatorView(format: $model.format,
                                     dateRangeIndex: $model.dateRangeIndex,
                                     contentCategory: $model.chosenBannedContentCategory,
                                     dates: model.restrictionDates)
                .disabled([DataTaskStatus.uninitiated, DataTaskStatus.pending].contains(model.dataTaskStatuses[.content]))
            }
            .onChange(of: model.format) {
                Task {
                    await model.fetchTimelineData()
                }
            }
            .onChange(of: model.dateRangeIndex) {
                Task {
                    await model.fetchRestrictedCards()
                }
            }
            .task {
                if [DataTaskStatus.uninitiated, DataTaskStatus.pending].contains(model.dataTaskStatuses[.timeline]) {
                    await model.fetchTimelineData()
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

private struct CardScoresView: View {
    @Binding var path: NavigationPath
    let content: [CardScoreEntry]
    
    var body: some View {
        LazyVStack {
            ForEach(content, id: \.self.card.cardID) { entry in
                let card = entry.card
                Button {
                    path.append(CardLinkDestinationValue(cardID: card.cardID, cardName: card.cardName))
                } label: {
                    GroupBox(label: Label("\(entry.score) points", systemImage: "medal.star.fill")) {
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
    RestrictedContentView()
}
