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
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Format")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Spacer()
                ForEach(BanListDatesView.formats, id: \.rawValue) { f in
                    TabButton(format: f, animmation: animation, selected: $format)
                    if BanListDatesView.formats.last != f {
                        Spacer()
                    }
                }
            }
            
            HStack {
                Text("Date Range")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Spacer()
                if isDataLoaded {
                    Text(dates[currentBanListPosition].effectiveDate)
                    + Text(" - ")
                    + Text((currentBanListPosition - 1 < 0) ? "???" : dates[currentBanListPosition - 1].effectiveDate)
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
        }
    }
}


private struct TabButton: View {
    var format: BanListFormat
    var animmation: Namespace.ID
    @Binding var selected: BanListFormat
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2)) {selected = format}
        })
        {
            Text(format.rawValue)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(selected == format ? .white : .primary)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .if(selected == format) {
                    $0.background {
                        Color.accentColor
                            .clipShape(Capsule())
                            .matchedGeometryEffect(id: "Tab", in: animmation)
                    }
                } else: {
                    $0.background {
                        Color.gray.opacity(0.3)
                        .clipShape(Capsule())
                    }
                }
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
