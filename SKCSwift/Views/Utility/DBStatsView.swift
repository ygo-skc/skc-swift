//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct DBStatsView: View {
    @Binding private var isDataInvalidated: Bool
    
    @State private var stats = SKCDatabaseStats(productTotal: 0, cardTotal: 0, banListTotal: 0)
    @State private var isDataLoaded = false
    
    init(isDataInvalidated: Binding<Bool> = .constant(false)) {
        self._isDataInvalidated = isDataInvalidated
    }
    
    func fetchData() {
        if !isDataLoaded || isDataInvalidated {
            self.isDataInvalidated = false
            
            request(url: dbStatsURL(), priority: 0.3) { (result: Result<SKCDatabaseStats, Error>) -> Void in
                switch result {
                case .success(let stats):
                    DispatchQueue.main.async {
                        self.stats = stats
                        self.isDataLoaded = true
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
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
                        DBStatView(count: stats.cardTotal.decimal, stat: "Cards", isDataLoaded: isDataLoaded)
                        DBStatView(count: stats.banListTotal.decimal, stat: "Ban Lists", isDataLoaded: isDataLoaded)
                        DBStatView(count: stats.productTotal.decimal, stat: "Products", isDataLoaded: isDataLoaded)
                    }
                    .padding(.horizontal)
                }
                .frame(
                    maxWidth: .infinity
                )
            }
            .onChange(of: $isDataInvalidated.wrappedValue, initial: true) {
                fetchData()
            }
        })
    }
}


private struct DBStatView: View {
    var count: String
    var stat: String
    var isDataLoaded: Bool
    
    var body: some View {
        VStack {
            if isDataLoaded {
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
    DBStatsView()
}
