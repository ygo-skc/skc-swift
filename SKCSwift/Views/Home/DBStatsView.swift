//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct DBStatsView: View, Equatable {
    static func == (lhs: DBStatsView, rhs: DBStatsView) -> Bool {
        lhs.dbStats == rhs.dbStats && lhs.isDataLoaded == rhs.isDataLoaded && lhs.networkError == rhs.networkError
    }
    
    let dbStats: SKCDatabaseStats
    let isDataLoaded: Bool
    let networkError: NetworkError?
    let retryCB: () async -> Void
    
    var body: some View {
        SectionView(header: "Content",
                    content: {
            VStack(alignment: .leading, spacing: 5) {
                if let networkError {
                    NetworkErrorView(error: networkError, action: { Task { await retryCB() } })
                } else {
                    Text("All data is provided by a collection of API's/DB's designed to provide the best Yu-Gi-Oh! information.")
                        .font(.callout)
                        .padding(.bottom)
                    
                    HStack {
                        Text("DB\nContents 🤓")
                            .font(.headline)
                            .fontWeight(.regular)
                            .padding(.trailing)
                        
                        FlowLayout(spacing: 15) {
                            DBStatView(count: (isDataLoaded) ? dbStats.cardTotal : -1, stat: "Cards")
                            DBStatView(count: (isDataLoaded) ? dbStats.banListTotal : -1, stat: "Ban Lists")
                            DBStatView(count: (isDataLoaded) ? dbStats.productTotal : -1, stat: "Products")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    Divider()
                        .padding(.vertical, 4)
                    
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
            }
            .frame(maxWidth: .infinity)
        })
    }
}

private struct DBStatView: View {
    let count: Int
    let stat: String
    
    var body: some View {
        VStack {
            if count >= 0 {
                Text(count.decimal)
            } else {
                PlaceholderView(width: 40, height: 20, radius: 5)
            }
            Text(stat)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

#Preview("Default") {
    DBStatsView(dbStats: SKCDatabaseStats(productTotal: 313, cardTotal: 13000, banListTotal: 67),
                isDataLoaded: true, networkError: nil, retryCB: {})
    .padding(.horizontal)
}

#Preview("Loading") {
    DBStatsView(dbStats: SKCDatabaseStats(productTotal: 0, cardTotal: 0, banListTotal: 0),
                isDataLoaded: false, networkError: nil, retryCB: {})
    .padding(.horizontal)
}

#Preview("Loaded - No Content") {
    DBStatsView(dbStats: SKCDatabaseStats(productTotal: 0, cardTotal: 0, banListTotal: 0),
                isDataLoaded: true, networkError: nil, retryCB: {})
    .padding(.horizontal)
}

#Preview("Network Error") {
    DBStatsView(dbStats: SKCDatabaseStats(productTotal: 313, cardTotal: 13000, banListTotal: 67),
                isDataLoaded: true, networkError: .timeout, retryCB: {})
    .padding(.horizontal)
}
