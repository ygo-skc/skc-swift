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
                                    format: model.format,
                                    restrictedCards: model.restrictedCards,
                                    scoreEntries: model.scoreEntries,
                                    timelineDTS: model.timelineDTS,
                                    contentDTS: model.contentDTS,
                                    timelineNE: model.timelineNE,
                                    contentNE: model.contentNE,
                                    timelineCB: { await model.fetchTimelineData() },
                                    contentCB: { await model.fetchRestrictedCards() }
                )
                .equatable()
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: mainSheetContentHeight)
                }
            } sheetContent: {
                RestrictedContentNavigatorView(format: $model.format,
                                               dateRangeIndex: $model.dateRangeIndex,
                                               contentCategory: $model.chosenBannedContentCategory,
                                               dates: model.restrictionDates,
                                               isDisabled: DataTaskStatusParser.isDataPending(model.timelineDTS) || DataTaskStatusParser.isDataPending(model.contentDTS))
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
}

#Preview() {
    RestrictedContentView()
}

private struct RestrictedCardsView: View, Equatable {
    static func == (lhs: RestrictedCardsView, rhs: RestrictedCardsView) -> Bool {
        lhs.format == rhs.format
        && lhs.timelineDTS == rhs.timelineDTS
        && lhs.contentDTS == rhs.contentDTS
        && lhs.timelineNE == rhs.timelineNE
        && lhs.contentNE == rhs.contentNE
        && lhs.restrictedCards == rhs.restrictedCards
    }
    
    @Binding var path: NavigationPath
    
    let format: CardRestrictionFormat
    let restrictedCards: [Card]
    let scoreEntries: [CardScoreEntry]
    
    let timelineDTS: DataTaskStatus
    let contentDTS: DataTaskStatus
    
    let timelineNE: NetworkError?
    let contentNE: NetworkError?
    
    let timelineCB: () async -> Void
    let contentCB: () async -> Void
    
    var body: some View {
        ScrollView {
            if timelineDTS == .done && (contentDTS == .done && contentDTS != .error) {
                SectionView(header: "\(format.rawValue) Content",
                            variant: .plain,
                            content: {
                    switch format {
                    case .md, .tcg:
                        BannedContentView(path: $path, content: restrictedCards)
                    case .genesys:
                        CardScoresView(path: $path, content: scoreEntries)
                    }
                    
                })
                .modifier(.parentView)
                .padding(.bottom, 0)
                .ygoNavigationDestination()
            }
        }
        .frame(maxWidth: .infinity)
        .scrollDisabled(DataTaskStatusParser.isDataPending(timelineDTS)
                        || DataTaskStatusParser.isDataPending(contentDTS)
                        || timelineNE != nil
                        || contentNE != nil)
        .overlay {
            if DataTaskStatusParser.isDataPending(timelineDTS)
                || (timelineDTS != .error && DataTaskStatusParser.isDataPending(contentDTS)) {
                ProgressView("Loading...")
                    .controlSize(.large)
            } else if let timelineNE {
                NetworkErrorView(error: timelineNE) {
                    Task {
                        await timelineCB()
                    }
                }
            } else if let contentNE {
                NetworkErrorView(error: contentNE) {
                    Task {
                        await contentCB()
                    }
                }
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
}

#Preview("Timeline pending") {
    @Previewable @State var path = NavigationPath()
    RestrictedCardsView(path: $path,
                        format: .md,
                        restrictedCards: [],
                        scoreEntries: [],
                        timelineDTS: .pending,
                        contentDTS: .pending,
                        timelineNE: nil,
                        contentNE: nil,
                        timelineCB: {},
                        contentCB: {})
}

#Preview("Timeline content pending") {
    @Previewable @State var path = NavigationPath()
    RestrictedCardsView(path: $path,
                        format: .md,
                        restrictedCards: [],
                        scoreEntries: [],
                        timelineDTS: .done,
                        contentDTS: .pending,
                        timelineNE: nil,
                        contentNE: nil,
                        timelineCB: {},
                        contentCB: {})
}

#Preview("Timeline error") {
    @Previewable @State var path = NavigationPath()
    RestrictedCardsView(path: $path,
                        format: .md,
                        restrictedCards: [],
                        scoreEntries: [],
                        timelineDTS: .error,
                        contentDTS: .pending,
                        timelineNE: .timeout,
                        contentNE: nil,
                        timelineCB: {},
                        contentCB: {})
}

#Preview("Content error") {
    @Previewable @State var path = NavigationPath()
    RestrictedCardsView(path: $path,
                        format: .md,
                        restrictedCards: [],
                        scoreEntries: [],
                        timelineDTS: .done,
                        contentDTS: .error,
                        timelineNE: nil,
                        contentNE: .timeout,
                        timelineCB: {},
                        contentCB: {})
}
