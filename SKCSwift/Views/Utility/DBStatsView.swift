//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct DBStatsView: View, Equatable {
    let stats: SKCDatabaseStats?
    
    var body: some View {
        SectionView(header: "Content",
                    content: {
            VStack(alignment: .leading, spacing: 5) {
                Text("All data is provided by a collection of API's/DB's designed to provide the best Yu-Gi-Oh! information.")
                    .padding(.bottom)
                    .font(.body)
                
                Text("DB Stats")
                    .font(.title3)
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        alignment: .center
                    )
                HStack {
                    Group {
                        DBStatView(count: stats?.cardTotal, stat: "Cards")
                        DBStatView(count: stats?.banListTotal, stat: "Ban Lists")
                        DBStatView(count: stats?.productTotal, stat: "Products")
                    }
                    .padding(.horizontal)
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
    DBStatsView(stats: nil)
}

#Preview {
    DBStatsView(stats: SKCDatabaseStats(productTotal: 100, cardTotal: 5000, banListTotal: 30))
}
