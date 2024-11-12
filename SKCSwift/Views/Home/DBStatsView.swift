//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct DBStatsView: View {
    let model: HomeViewModel
    
    var body: some View {
        SectionView(header: "Content",
                    content: {
            if let networkError = model.requestErrors[.dbStats, default: nil] {
                NetworkErrorView(error: networkError, action: { Task { await model.fetchDBStatsData() } })
            } else {
                VStack(spacing: 5) {
                    Text("All data is provided by a collection of API's/DB's designed to provide the best Yu-Gi-Oh! information.")
                        .padding(.bottom)
                        .font(.body)
                        .multilineTextAlignment(.center)
                    
                    Text("DB Stats")
                        .font(.title3)
                    HStack {
                        Group {
                            DBStatView(count: model.dbStats?.cardTotal, stat: "Cards")
                            DBStatView(count: model.dbStats?.banListTotal, stat: "Ban Lists")
                            DBStatView(count: model.dbStats?.productTotal, stat: "Products")
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                    
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
                .frame(maxWidth: .infinity)
            }
        })
    }
}

private struct DBStatView: View {
    let count: String?
    let stat: String
    
    init(count: Int?, stat: String) {
        self.count = count?.decimal
        self.stat = stat
    }
    
    var body: some View {
        VStack {
            if let count {
                Text(count)
                    .font(.title3)
            } else {
                PlaceholderView(width: 25, height: 20, radius: 5)
            }
            Text(stat)
                .font(.headline)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    let model = HomeViewModel()
    DBStatsView(model: model)
}

#Preview {
    let model = HomeViewModel()
    DBStatsView(model: model)
        .task {
            await model.fetchDBStatsData()
        }
}
