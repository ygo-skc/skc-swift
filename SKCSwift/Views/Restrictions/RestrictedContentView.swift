//
//  RestrictedContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 6/10/23.
//

import SwiftUI
import YGOService

private func isOverlayVisible(timelineDTS: DataTaskStatus,
                              contentDTS: DataTaskStatus,
                              timelineNE: NetworkError?,
                              contentNE: NetworkError?) -> Bool {
    return DataTaskStatusParser.isDataPending(timelineDTS) || DataTaskStatusParser.isDataPending(contentDTS) || timelineNE != nil || contentNE != nil
}

struct RestrictedContentView: View {
    @State private var mainSheetContentHeight: CGFloat = 0
    @State private var path = NavigationPath()
    @State private var model = RestrictedCardsViewModel()
    
    @State private var isSettingsSheetPresented = false
    @Namespace private var animation
    
    private var sortToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                ForEach(RestrictedContentSortOrder.allCases, id: \.self) { sortOption in
                    Button(action: {model.sort = sortOption}) {
                        if model.sort == sortOption {
                            Image(systemName: "checkmark")
                        }
                        Text(sortOption.title)
                        if model.sort == sortOption {
                            Text(sortOption.subtitle)
                        }
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
            }
        }
        .modify {
            if #available(iOS 26.0, *) {
                $0.matchedTransitionSource(id: "genesysToolbar", in: animation)
            } else {
                $0
            }
        }
    }
    
    @ViewBuilder
    private var contentHeader: some View{
        VStack(alignment: .leading, spacing: 5) {
            if let chosenRestrictedContentDate = model.chosenRestrictedContentDate, chosenRestrictedContentDate > Date.now {
                Label {
                    Text("Selected range is effective in \(abs(chosenRestrictedContentDate.timeIntervalSinceNow()) + 1) day(s)")
                } icon: {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(.orange)
                }
            }
            
            if model.format == .genesys {
                Label(
                    "Each card in **Genesys** is given a point/score. Utilize below list to see scores for given date range. Cards not explicitly on list cost 0 points. [More info](https://www.yugioh-card.com/en/genesys)",
                    systemImage: "info.circle")
                .font(.callout)
            } else {
                nonGenesysContentExplainer
            }
            Label("\(model.totalEntries) entries", systemImage: "sum")
                .font(.callout)
        }
        .padding(.bottom, 4)
    }
    
    @ViewBuilder
    private var nonGenesysContentExplainer: some View {
        Label {
            switch(model.chosenBannedContentCategory) {
            case .forbidden:
                Text("Below cards cannot be used in the main/side/extra decks")
            case .limited:
                Text("Only one copy of the below cards can be used in the main/side/extra decks")
            case .semiLimited:
                Text("Only two copy of the below cards can be used in the main/side/extra decks")
            }
        } icon: {
            switch(model.chosenBannedContentCategory) {
            case .forbidden:
                Image(systemName: "x.circle.fill")
                    .foregroundColor(.red)
            case .limited:
                Image(systemName: "1.circle.fill")
                    .foregroundColor(.yellow)
            case .semiLimited:
                Image(systemName: "2.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .font(.callout)
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            SegmentedView(mainSheetContentHeight: $mainSheetContentHeight) {
                RestrictedCardsView(
                    format: model.format,
                    restrictedCards: model.restrictedCards,
                    scoreEntries: model.scoreEntries,
                    isOverlayVisible: isOverlayVisible(
                        timelineDTS: model.timelineDTS,
                        contentDTS: model.contentDTS,
                        timelineNE: model.timelineNE,
                        contentNE: model.contentNE)) {
                            contentHeader
                        } overlay: {
                            RestrictedCardsViewOverlay(
                                timelineDTS: model.timelineDTS,
                                contentDTS: model.contentDTS,
                                timelineNE: model.timelineNE,
                                contentNE: model.contentNE,
                                timelineCB: { await model.fetchTimelineData() },
                                contentCB: { await model.fetchRestrictedCards() })
                        }
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
                        .toolbar {
                            if model.format == .genesys
                                && !isOverlayVisible(timelineDTS: model.timelineDTS, contentDTS: model.contentDTS,
                                                     timelineNE: model.timelineNE, contentNE: model.contentNE) {
                                sortToolbarItem
                            }
                        }
            } sheetContent: {
                RestrictedContentNavigatorView(
                    format: $model.format,
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
            .onChange(of: model.sort) {
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

private struct RestrictedCardsView<Header: View, Overlay: View & Equatable>: View, Equatable {
    static func == (lhs: RestrictedCardsView, rhs: RestrictedCardsView) -> Bool {
        lhs.isOverlayVisible == rhs.isOverlayVisible
        && lhs.restrictedCards == rhs.restrictedCards
        && lhs.scoreEntries == rhs.scoreEntries
        && lhs.overlay == rhs.overlay
    }
    
    let format: CardRestrictionFormat
    let restrictedCards: [YGOCard]
    let scoreEntries: [CardScoreEntry]
    
    let isOverlayVisible: Bool
    
    let header: Header
    let overlay: Overlay
    
    init(
        format: CardRestrictionFormat,
        restrictedCards: [YGOCard],
        scoreEntries: [CardScoreEntry],
        isOverlayVisible: Bool,
        @ViewBuilder header: () -> Header,
        @ViewBuilder overlay: () -> Overlay) {
            self.format = format
            self.restrictedCards = restrictedCards
            self.scoreEntries = scoreEntries
            
            self.isOverlayVisible = isOverlayVisible
            
            self.header = header()
            self.overlay = overlay()
        }
    
    var body: some View {
        ScrollView {
            if !isOverlayVisible {
                VStack(alignment: .leading) {
                    header
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
        .frame(maxWidth: .infinity) // needed by overlay
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
            ProgressView("Loading…")
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


#Preview("Timeline pending") {
    let timelineDTS: DataTaskStatus = .pending
    let contentDTS: DataTaskStatus = .pending
    let timelineNE: NetworkError? = nil
    let contentNE: NetworkError? = nil
    
    RestrictedCardsView(format: .md,
                        restrictedCards: [],
                        scoreEntries: [],
                        isOverlayVisible: isOverlayVisible(timelineDTS: timelineDTS, contentDTS: contentDTS, timelineNE: timelineNE, contentNE: contentNE)) {
        EmptyView()
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
        EmptyView()
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
        EmptyView()
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
        EmptyView()
    } overlay: {
        RestrictedCardsViewOverlay(timelineDTS: timelineDTS,
                                   contentDTS: contentDTS,
                                   timelineNE: timelineNE,
                                   contentNE: contentNE,
                                   timelineCB: {},
                                   contentCB: {})
    }
}
