//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct BanListDatesView: View {
    @State private var dates = [BanListDate]()
    @State private var isDataLoaded = false
    @State private var currentBanListPosition = 0
    
    func fetchData() {
        if isDataLoaded {
            return
        }
        
        request(url: banListDatesURL(format: "md")) { (result: Result<BanListDates, Error>) -> Void in
            DispatchQueue.main.async {
                switch result {
                case .success(let dates):
                    self.dates = dates.banListDates
                    self.currentBanListPosition = 0
                    self.isDataLoaded = true
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if (isDataLoaded) {
                HStack {
                    Text("Date Range: ")
                        .fontWeight(.bold)
                    + Text(dates[currentBanListPosition].effectiveDate)
                    + Text(" - ")
                    + Text((currentBanListPosition - 1 < 0) ? "???" : dates[currentBanListPosition - 1].effectiveDate)
                }
                
                HStack {
                    Text("Format: ")
                        .fontWeight(.bold)
                    + Text("TCG")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.horizontal)
        .onAppear {
            fetchData()
        }
    }
}

struct BanListDatesView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            BanListDatesView()
                .padding(.horizontal)
        }
    }
}
