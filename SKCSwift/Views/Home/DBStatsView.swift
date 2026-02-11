//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct DBStatsView: View, Equatable {
    static func == (lhs: DBStatsView, rhs: DBStatsView) -> Bool {
        lhs.dbStats == rhs.dbStats
        && lhs.dataTaskStatus == rhs.dataTaskStatus
    }
    
    let dbStats: SKCDatabaseStats
    let dataTaskStatus: DataTaskStatus
    let networkError: NetworkError?
    let retryCB: () async -> Void
    
    @ViewBuilder
    private var disclosure: some View {
        Group {
            Text("Konami owns all rights to Yu-Gi-Oh! and all card images used in this app.")
            Text("This app is not affiliated with Konami and all assets are used under Fair Use.")
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
               let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                Text("App Version \(appVersion)(\(build))")
                    .italic()
            }
        }
        .padding(.bottom, 2)
        .font(.footnote)
    }
    
    @ViewBuilder
    private var stats: some View {
        Text("All data is provided by a collection of API's/DB's designed to provide the best Yu-Gi-Oh! information.")
            .font(.callout)
            .padding(.bottom)
        
        HStack {
            Text("DB\nData")
                .font(.headline)
                .fontWeight(.regular)
                .padding(.trailing)
            Spacer()
            FlowLayout(spacing: 15) {
                DBStatView(count: dbStats.cardTotal, stat: "Cards", isDataLoaded: dataTaskStatus == .done)
                DBStatView(count: dbStats.banListTotal, stat: "Ban Lists", isDataLoaded: dataTaskStatus == .done)
                DBStatView(count: dbStats.productTotal, stat: "Products", isDataLoaded: dataTaskStatus == .done)
            }
            Spacer()
        }
    }
    
    var body: some View {
        SectionView(header: "Content",
                    content: {
            if let networkError {
                NetworkErrorView(error: networkError, action: { Task { await retryCB() } })
            } else {
                stats
                Divider()
                    .padding(.vertical, 4)
                disclosure
            }
        })
    }
}

private struct DBStatView: View {
    let count: Int
    let stat: String
    let isDataLoaded: Bool
    
    init(count: Int, stat: String, isDataLoaded: Bool) {
        self.count = (!isDataLoaded) ? -999 : count
        self.stat = stat
        self.isDataLoaded = isDataLoaded
    }
    
    var body: some View {
        VStack {
            Text(count.decimal)
            Text(stat)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .if(!isDataLoaded) {
            $0.redacted(reason: .placeholder)
        }
    }
}

#Preview("Default") {
    DBStatsView(dbStats: SKCDatabaseStats(productTotal: 313, cardTotal: 13000, banListTotal: 67),
                dataTaskStatus: .done, networkError: nil, retryCB: {})
    .padding(.horizontal)
}

#Preview("Loading") {
    DBStatsView(dbStats: SKCDatabaseStats(productTotal: 0, cardTotal: 0, banListTotal: 0),
                dataTaskStatus: .pending, networkError: nil, retryCB: {})
    .padding(.horizontal)
}

#Preview("Loaded - No Content") {
    DBStatsView(dbStats: SKCDatabaseStats(productTotal: 0, cardTotal: 0, banListTotal: 0),
                dataTaskStatus: .done, networkError: nil, retryCB: {})
    .padding(.horizontal)
}

#Preview("Network Error") {
    DBStatsView(dbStats: SKCDatabaseStats(productTotal: 313, cardTotal: 13000, banListTotal: 67),
                dataTaskStatus: .error, networkError: .timeout, retryCB: {})
    .padding(.horizontal)
}
