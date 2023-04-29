//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct DBStatsView: View {
    @State private(set) var stats = SKCDatabaseStats(productTotal: 0, cardTotal: 0, banListTotal: 0)
    @State private(set) var isDataLoaded = false
    
    func fetchData() {
        if isDataLoaded {
            return
        }
        request(url: dbStatsURL()) { (result: Result<SKCDatabaseStats, Error>) -> Void in
            DispatchQueue.main.async {
                switch result {
                case .success(let stats):
                    self.stats = stats
                    self.isDataLoaded = true
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    var body: some View {
        SectionView(header: "Content",
                    disableDestination: true,
                    destination: {EmptyView()},
                    content: {
            VStack(alignment: .leading) {
                Text("All data is provided by a collection of API's/DB's designed to provide the best Yu-Gi-Oh! information.")
                    .font(.body)
                
                Text("DB Stats")
                    .font(.title2)
                    .padding(.vertical, 2)
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        alignment: .center
                    )
                HStack {
                    DBStatView(count: stats.cardTotal.decimal, stat: "Cards")
                        .padding(.horizontal)
                    DBStatView(count: stats.banListTotal.decimal, stat: "Ban Lists")
                        .padding(.horizontal)
                    DBStatView(count: stats.productTotal.decimal, stat: "Products")
                        .padding(.horizontal)
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity
                )
            }
            .onAppear {
                fetchData()
            }
        })
    }
}


private struct DBStatView: View {
    var count: String
    var stat: String
    
    var body: some View {
        VStack {
            Text(count)
                .font(.title3)
            Text(stat)
                .font(.headline)
                .fontWeight(.heavy)
        }
    }
}

struct DBStatsView_Previews: PreviewProvider {
    static var previews: some View {
        DBStatsView()
    }
}
