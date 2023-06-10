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
    
    func fetchData() {
        if isDataLoaded {
            return
        }
        
        request(url: banListDatesURL(format: "md")) { (result: Result<BanListDates, Error>) -> Void in
            DispatchQueue.main.async {
                switch result {
                case .success(let dates):
                    self.dates = dates.banListDates
                    self.isDataLoaded = true
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            
        }
        .frame(maxWidth: .infinity)
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
