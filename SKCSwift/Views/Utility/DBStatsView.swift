//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct DBStatsView: View {
    @Binding private var isDataInvalidated: Bool
    
    @State var stats = SKCDatabaseStats(productTotal: 0, cardTotal: 0, banListTotal: 0)
    @State var isDataLoaded = false
    
    init(isDataInvalidated: Binding<Bool> = .constant(false)) {
        self._isDataInvalidated = isDataInvalidated
    }
    
    func fetchData() {
        if !isDataLoaded || isDataInvalidated {
            self.isDataInvalidated = false
            
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
    }
    
    var body: some View {
        SectionView(header: "Content",
                    disableDestination: true,
                    destination: {EmptyView()},
                    content: {
            VStack(alignment: .leading, spacing: 5) {
                Text("All data is provided by a collection of API's/DB's designed to provide the best Yu-Gi-Oh! information.")
                    .font(.body)
                
                Text("DB Stats")
                    .font(.title2)
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
                    minWidth: 0,
                    maxWidth: .infinity
                )
            }
            .task(priority: .background) {
                fetchData()
            }
            .onChange(of: $isDataInvalidated.wrappedValue) { _ in
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
                .fontWeight(.heavy)
        }
    }
}

struct DBStatsView_Previews: PreviewProvider {
    static var previews: some View {
        DBStatsView()
    }
}
