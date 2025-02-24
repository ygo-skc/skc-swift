//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct DBStatsView: View {
    let dbStats: SKCDatabaseStats
    let isDataLoaded: Bool
    let networkError: NetworkError?
    let retryCB: () async -> Void
    
    var body: some View {
        SectionView(header: "Content",
                    content: {
            VStack(spacing: 5) {
                if let networkError {
                    NetworkErrorView(error: networkError, action: { Task { await retryCB() } })
                } else {
                    Text("All data is provided by a collection of API's/DB's designed to provide the best Yu-Gi-Oh! information.")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                    
                    Text("DB Stats")
                        .font(.headline)
                    HStack {
                        Group {
                            DBStatView(count: (isDataLoaded) ? dbStats.cardTotal : -1, stat: "Cards")
                            DBStatView(count: (isDataLoaded) ? dbStats.banListTotal : -1, stat: "Ban Lists")
                            DBStatView(count: (isDataLoaded) ? dbStats.productTotal : -1, stat: "Products")
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                        .padding(.vertical)
                    
                    Group {
                        Text("Konami owns all rights to Yu-Gi-Oh! and all card images used in this app.")
                        Text("This app is not affiliated with Konami and all assets are used under Fair Use.")
                        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                            Text("v\(appVersion)(\(build))")
                        }
                    }
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
        })
    }
}

private struct DBStatView: View {
    let count: Int
    let stat: String
    
    init(count: Int, stat: String) {
        self.count = count
        self.stat = stat
    }
    
    var body: some View {
        VStack {
            if count >= 0 {
                Text(count.decimal)
                    .font(.title3)
            } else {
                PlaceholderView(width: 25, height: 20, radius: 5)
            }
            Text(stat)
                .font(.subheadline)
                .fontWeight(.heavy)
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
