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
                RestrictedCardsView(path: $path,
                                    mainSheetContentHeight: mainSheetContentHeight,
                                    format: model.format,
                                    restrictedCards: model.restrictedCards,
                                    scoreEntries: model.scoreEntries,
                                    timelineDTS: model.timelineDTS,
                                    contentDTS: model.contentDTS)
                
            } sheetContent: {
                BanListNavigatorView(format: $model.format,
                                     dateRangeIndex: $model.dateRangeIndex,
                                     contentCategory: $model.chosenBannedContentCategory,
                                     dates: model.restrictionDates)
                .disabled(DataTaskStatusParser.isDataPending(model.timelineDTS) || DataTaskStatusParser.isDataPending(model.contentDTS))
            }
            .overlay {
                if DataTaskStatusParser.isDataPending(model.timelineDTS) || DataTaskStatusParser.isDataPending(model.contentDTS) {
                    ProgressView("Loading...")
                        .controlSize(.large)
                }
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
                if DataTaskStatusParser.isDataPending(model.timelineDTS) {
                    await model.fetchTimelineData()
                }
            }
        }
    }
    
    private struct RestrictedCardsView: View {
        @Binding var path: NavigationPath
        let mainSheetContentHeight: CGFloat
        let format: CardRestrictionFormat
        let restrictedCards: [Card]
        let scoreEntries: [CardScoreEntry]
        let timelineDTS: DataTaskStatus
        let contentDTS: DataTaskStatus
        
        var body: some View {
            ScrollView {
                SectionView(header: "\(format.rawValue) Content",
                            variant: .plain,
                            content: {
                    if timelineDTS == .done && contentDTS == .done {
                        switch format {
                        case .md, .tcg:
                            BannedContentView(path: $path, content: restrictedCards)
                        case .genesys:
                            CardScoresView(path: $path, content: scoreEntries)
                        }
                    }
                })
                .modifier(.parentView)
                .padding(.bottom, 0)
                .ygoNavigationDestination()}
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: mainSheetContentHeight)
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
    }
}

#Preview() {
    RestrictedContentView()
}
