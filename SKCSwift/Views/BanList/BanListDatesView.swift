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
    @State private var format: BanListFormat = .tcg
    
    @Namespace private var animation
    
    private static let formats: [BanListFormat] = [.tcg, .md, .dl]
    
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
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Format")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .padding(.trailing)
                ForEach(BanListDatesView.formats, id: \.rawValue) { f in
                    TabButton(selected: $format, value: f, animmation: animation)
                    if BanListDatesView.formats.last != f {
                        Spacer()
                    }
                }
            }
            
            HStack {
                Text("Range")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .padding(.trailing)
                if isDataLoaded {
                    Spacer()
                    InlineDateView(date: dates[currentBanListPosition].effectiveDate)
                    Image(systemName: "arrowshape.right.fill")
                    if currentBanListPosition == 0 {
                        Text("Present")
                            .font(.headline)
                            .fontWeight(.bold)
                    } else {
                        InlineDateView(date: dates[currentBanListPosition - 1].effectiveDate)
                    }
                    Spacer()
                } else {
                    PlaceholderView(width: 75, height: 20, radius: 5)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.horizontal)
        .task(priority: .background) {
            fetchData()
        }
        .onChange(of: $format.wrappedValue) { _ in
            fetchData()
        }.background(GeometryReader { geometry in
            Color.clear.preference(
                key: BanListDatesBottomViewMinHeightPreferenceKey.self,
                value: geometry.size.height
            )
        })
    }
}

struct BanListDatesBottomViewMinHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
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
