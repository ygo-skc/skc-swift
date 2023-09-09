//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct BanListOptionsView: View {
    @Binding var chosenFormat: BanListFormat
    @Binding var chosenDateRange: Int
    @Binding var banListDates: [BanListDate]
    
    var body: some View {
        VStack {
            BanListFormatsView(chosenFormat: $chosenFormat)
            BanListDatesView(chosenFormat: $chosenFormat, chosenDateRange: $chosenDateRange, banListDates: $banListDates)
        }
    }
}

private struct BanListDatesView: View {
    @Binding var chosenFormat: BanListFormat
    @Binding var chosenDateRange: Int
    @Binding var banListDates: [BanListDate]
    
    @State private var isDataLoaded = false
    
    private func fetchData() {
        request(url: banListDatesURL(format: "\(chosenFormat)")) { (result: Result<BanListDates, Error>) -> Void in
            DispatchQueue.main.async {
                switch result {
                case .success(let dates):
                    self.banListDates = dates.banListDates
                    self.chosenDateRange = 0
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
            ChosenDateView(isDataLoaded: isDataLoaded, chosenDateRange: chosenDateRange, banListDates: banListDates)
            Image(systemName: "arrowshape.right.fill")
                .padding(.horizontal)
            ChosenDateView(isDataLoaded: isDataLoaded, chosenDateRange: chosenDateRange - 1, banListDates: banListDates)
            Spacer()
        }
        .task(priority: .background) {
            fetchData()
        }
        .onChange(of: $chosenFormat.wrappedValue) { _ in
            self.isDataLoaded = false
            fetchData()
        }
    }
}


private struct ChosenDateView: View {
    let isDataLoaded: Bool
    let chosenDateRange: Int
    let banListDates: [BanListDate]
    
    var body: some View {
        if isDataLoaded && !banListDates.isEmpty {
            if chosenDateRange == -1 {
                Text("Present")
                    .font(.headline)
                    .fontWeight(.bold)
            } else {
                InlineDateView(date: banListDates[chosenDateRange].effectiveDate)
            }
        }
        else {
            PlaceholderView(width: 70, height: 16, radius: 5)
        }
    }
}


struct BanListFormatsView: View {
    @Binding var chosenFormat: BanListFormat
    
    @Namespace private var animation
    
    private static let formats: [BanListFormat] = [.tcg, .md, .dl]
    
    var body: some View {
        HStack {
            Text("Format")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .padding(.trailing)
            ForEach(BanListFormatsView.formats, id: \.rawValue) { format in
                TabButton(selected: $chosenFormat, value: format, animmation: animation)
                if BanListFormatsView.formats.last != format {
                    Spacer()
                }
            }
        }
    }
}

struct BanListOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        _BanListOptionsView()
    }
    
    private struct _BanListOptionsView : View {
        @State var chosenFormat: BanListFormat = .tcg
        @State var chosenDateRange: Int = 0
        @State var banListDates = [BanListDate]()
        
        var body: some View {
            BanListOptionsView(chosenFormat: $chosenFormat, chosenDateRange: $chosenDateRange, banListDates: $banListDates)
        }
    }
}

struct BanListFormatsView_Previews: PreviewProvider {
    static var previews: some View {
        _BanListFormatsView()
    }
    
    private struct _BanListFormatsView : View {
        @State var chosenFormat: BanListFormat = .tcg
        
        var body: some View {
            BanListFormatsView(chosenFormat: $chosenFormat)
        }
    }
}

struct BanListDatesView_Previews: PreviewProvider {
    static var previews: some View {
        _BanListDatesView()
    }
    
    private struct _BanListDatesView : View {
        @State var chosenFormat: BanListFormat = .tcg
        @State var chosenDateRange: Int = 0
        @State var banListDates = [BanListDate]()
        
        var body: some View {
            BanListDatesView(chosenFormat: $chosenFormat, chosenDateRange: $chosenDateRange, banListDates: $banListDates)
        }
    }
}
