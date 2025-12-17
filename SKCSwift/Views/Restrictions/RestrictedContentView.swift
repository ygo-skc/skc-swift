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
                RestrictedCardsView(format: model.format,
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
                .navigationTitle("Restrictions")
                .modify {
                    if #available(iOS 26.0, *) {
                        $0.navigationSubtitle("\(model.format.rawValue) format")
                    } else {
                        $0
                    }
                }
                .navigationBarTitleDisplayMode(.large)
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
                VStack {
                    switch format {
                    case .md, .tcg:
                        CardListView(cards: restrictedCards)
                    case .genesys:
                        CardListView(cards: scoreEntries.map({ $0.card }), label: { ind in
                            Label("\(scoreEntries[ind].score) points", systemImage: "medal.star.fill")
                        })
                    }
                }
                .modifier(.parentView)
            }
        }
        .ygoNavigationDestination()
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
}

#Preview("Timeline pending") {
    RestrictedCardsView(format: .md,
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
    RestrictedCardsView(format: .md,
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
    RestrictedCardsView(format: .md,
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
    RestrictedCardsView(format: .md,
                        restrictedCards: [],
                        scoreEntries: [],
                        timelineDTS: .done,
                        contentDTS: .error,
                        timelineNE: nil,
                        contentNE: .timeout,
                        timelineCB: {},
                        contentCB: {})
}
