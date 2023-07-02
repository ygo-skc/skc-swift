//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct BanListDatesView: View {
    @Binding var format: BanListFormat
    @State private var dates = [BanListDate]()
    @State private var isDataLoaded = false
    @State private var currentBanListPosition = 0
    
    private func fetchData() {
        request(url: banListDatesURL(format: "\(format)")) { (result: Result<BanListDates, Error>) -> Void in
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
        HStack {
            Text("Range")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .padding(.trailing)
            
            Spacer()
            if isDataLoaded {
                InlineDateView(date: dates[currentBanListPosition].effectiveDate)
            }
            else {
                PlaceholderView(width: 60, height: 18, radius: 5)
            }
            Image(systemName: "arrowshape.right.fill")
                .padding(.horizontal)
            if isDataLoaded {
                if currentBanListPosition == 0 {
                    Text("Present")
                        .font(.headline)
                        .fontWeight(.bold)
                } else {
                    InlineDateView(date: dates[currentBanListPosition - 1].effectiveDate)
                }
            }
            else {
                PlaceholderView(width: 60, height: 18, radius: 5)
            }
            Spacer()
        }
        .task(priority: .background) {
            fetchData()
        }
        .onChange(of: $format.wrappedValue) { _ in
            self.isDataLoaded = false
            fetchData()
        }
    }
}

struct BanListDatesBottomViewMinHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

//struct BanListDatesView_Previews: PreviewProvider {
//    static var previews: some View {
//        BanListDatesView()
//            .padding(.horizontal)
//    }
//}
