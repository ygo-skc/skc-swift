//
//  RestrictedContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/10/23.
//

import SwiftUI

private func isOverlayVisible(timelineDTS: DataTaskStatus,contentDTS: DataTaskStatus,
                              timelineNE: NetworkError?, contentNE: NetworkError?) -> Bool {
    return DataTaskStatusParser.isDataPending(timelineDTS) || DataTaskStatusParser.isDataPending(contentDTS) || timelineNE != nil || contentNE != nil
}

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
                                    isOverlayVisible: isOverlayVisible(timelineDTS: model.timelineDTS,
                                                                       contentDTS: model.contentDTS,
                                                                       timelineNE: model.timelineNE,
                                                                       contentNE: model.contentNE)) {
                    RestrictedCategoryExplanationView(category: model.chosenBannedContentCategory)
                } overlay: {
                    RestrictedCardsViewOverlay(timelineDTS: model.timelineDTS,
                                               contentDTS: model.contentDTS,
                                               timelineNE: model.timelineNE,
                                               contentNE: model.contentNE,
                                               timelineCB: { await model.fetchTimelineData() },
                                               contentCB: { await model.fetchRestrictedCards() })
                    .equatable()
                }.equatable()
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
                                               isDisabled: DataTaskStatusParser.isDataPending(model.timelineDTS)
                                               || DataTaskStatusParser.isDataPending(model.contentDTS))
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

private struct RestrictedCardsView<CategoryExplanation: View, Overlay: View>: View, Equatable {
    static func == (lhs: RestrictedCardsView, rhs: RestrictedCardsView) -> Bool {
        lhs.isOverlayVisible == rhs.isOverlayVisible
        && lhs.restrictedCards == rhs.restrictedCards
        && lhs.scoreEntries == rhs.scoreEntries
    }
    
    let format: CardRestrictionFormat
    let restrictedCards: [YGOCard]
    let scoreEntries: [CardScoreEntry]
    
    let isOverlayVisible: Bool
    
    let categoryExplanation: CategoryExplanation
    let overlay: Overlay
    
    init(format: CardRestrictionFormat,
         restrictedCards: [YGOCard],
         scoreEntries: [CardScoreEntry],
         isOverlayVisible: Bool,
         @ViewBuilder categoryExplanation: () -> CategoryExplanation,
         @ViewBuilder overlay: () -> Overlay) {
        self.format = format
        self.restrictedCards = restrictedCards
        self.scoreEntries = scoreEntries
        
        self.isOverlayVisible = isOverlayVisible
        
        self.categoryExplanation = categoryExplanation()
        self.overlay = overlay()
    }
    
    var body: some View {
        ScrollView {
            if !isOverlayVisible {
                VStack {
                    switch format {
                    case .md, .tcg:
                        categoryExplanation
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
        .scrollDisabled(isOverlayVisible)
        .overlay {
            overlay
        }
    }
}

private struct RestrictedCardsViewOverlay: View, Equatable {
    static func == (lhs: RestrictedCardsViewOverlay, rhs: RestrictedCardsViewOverlay) -> Bool {
        lhs.timelineDTS == rhs.timelineDTS
        && lhs.contentDTS == rhs.contentDTS
        && lhs.timelineNE == rhs.timelineNE
        && lhs.contentNE == rhs.contentNE
    }
    
    let timelineDTS: DataTaskStatus
    let contentDTS: DataTaskStatus
    
    let timelineNE: NetworkError?
    let contentNE: NetworkError?
    
    let timelineCB: () async -> Void
    let contentCB: () async -> Void
    
    var body: some View {
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

private struct RestrictedCategoryExplanationView: View {
    private let label: String
    private let systemImage: String
    private let color: Color
    
    init(category: BannedContentCategory) {
        switch(category) {
        case .forbidden:
            self.label = "Below cards cannot be used in the main/side/extra decks"
            self.systemImage = "x.circle.fill"
            self.color = .dateRed
        case .limited:
            self.label = "Only one copy of the below cards can be used in the main/side/extra decks"
            self.systemImage = "1.circle.fill"
            self.color = .yellow
        case .semiLimited:
            self.label = "Only one copy of the below cards can be used in the main/side/extra decks"
            self.systemImage = "2.circle.fill"
            self.color = .green
        }
    }
    
    var body: some View {
        Label {
            Text(label)
        } icon: {
            Image(systemName: systemImage)
                .foregroundColor(color)
        }
        .font(.callout)
        .padding(.bottom)
    }
}


#Preview("Timeline pending") {
    let timelineDTS: DataTaskStatus = .pending
    let contentDTS: DataTaskStatus = .pending
    let timelineNE: NetworkError? = nil
    let contentNE: NetworkError? = nil
    
    RestrictedCardsView(format: .md,
                        restrictedCards: [],
                        scoreEntries: [],
                        isOverlayVisible: isOverlayVisible(timelineDTS: timelineDTS, contentDTS: contentDTS, timelineNE: timelineNE, contentNE: contentNE)) {
        RestrictedCategoryExplanationView(category: .forbidden)
    } overlay: {
        RestrictedCardsViewOverlay(timelineDTS: timelineDTS,
                                   contentDTS: contentDTS,
                                   timelineNE: timelineNE,
                                   contentNE: contentNE,
                                   timelineCB: {},
                                   contentCB: {})
    }
}

#Preview("Content pending") {
    let timelineDTS: DataTaskStatus = .done
    let contentDTS: DataTaskStatus = .pending
    let timelineNE: NetworkError? = nil
    let contentNE: NetworkError? = nil
    
    RestrictedCardsView(format: .md,
                        restrictedCards: [],
                        scoreEntries: [],
                        isOverlayVisible: isOverlayVisible(timelineDTS: timelineDTS, contentDTS: contentDTS, timelineNE: timelineNE, contentNE: contentNE)) {
        RestrictedCategoryExplanationView(category: .forbidden)
    } overlay: {
        RestrictedCardsViewOverlay(timelineDTS: timelineDTS,
                                   contentDTS: contentDTS,
                                   timelineNE: timelineNE,
                                   contentNE: contentNE,
                                   timelineCB: {},
                                   contentCB: {})
    }
}

#Preview("Timeline error") {
    let timelineDTS: DataTaskStatus = .error
    let contentDTS: DataTaskStatus = .pending
    let timelineNE: NetworkError? = .timeout
    let contentNE: NetworkError? = nil
    
    RestrictedCardsView(format: .md,
                        restrictedCards: [],
                        scoreEntries: [],
                        isOverlayVisible: isOverlayVisible(timelineDTS: timelineDTS, contentDTS: contentDTS, timelineNE: timelineNE, contentNE: contentNE)) {
        RestrictedCategoryExplanationView(category: .forbidden)
    } overlay: {
        RestrictedCardsViewOverlay(timelineDTS: timelineDTS,
                                   contentDTS: contentDTS,
                                   timelineNE: timelineNE,
                                   contentNE: contentNE,
                                   timelineCB: {},
                                   contentCB: {})
    }
}

#Preview("Content error") {
    let timelineDTS: DataTaskStatus = .done
    let contentDTS: DataTaskStatus = .error
    let timelineNE: NetworkError? = nil
    let contentNE: NetworkError? = .timeout
    
    RestrictedCardsView(format: .md,
                        restrictedCards: [],
                        scoreEntries: [],
                        isOverlayVisible: isOverlayVisible(timelineDTS: timelineDTS, contentDTS: contentDTS, timelineNE: timelineNE, contentNE: contentNE)) {
        RestrictedCategoryExplanationView(category: .forbidden)
    } overlay: {
        RestrictedCardsViewOverlay(timelineDTS: timelineDTS,
                                   contentDTS: contentDTS,
                                   timelineNE: timelineNE,
                                   contentNE: contentNE,
                                   timelineCB: {},
                                   contentCB: {})
    }
}
