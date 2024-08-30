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
    @State private var showDateSelectorSheet = false
    
    private func fetchData() async {
        if !isDataLoaded {
            switch await data(BanListDates.self, url: banListDatesURL(format: "\(chosenFormat)")) {
            case .success(let dates):
                DispatchQueue.main.async {
                    self.banListDates = dates.banListDates
                    self.chosenDateRange = 0
                    self.isDataLoaded = true
                }
            case .failure(_): break
            }
        }
    }
    
    var body: some View {
        HStack {
            Text("Range")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.trailing)
            
            Button() {
                showDateSelectorSheet.toggle()
            } label: {
                if !banListDates.isEmpty {
                    BanListDateRangeView(fromDate: banListDates[chosenDateRange].effectiveDate, toDate: (chosenDateRange == 0) ? nil : banListDates[chosenDateRange - 1].effectiveDate)
                }
            }
            .buttonStyle(.bordered)
            .tint(Color.accentColor)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
        }
        .onChange(of: $chosenFormat.wrappedValue, initial: true) {
            self.isDataLoaded = false
            Task {
                // TODO: can this be improved?
                await fetchData()
            }
        }
        .popover(isPresented: $showDateSelectorSheet) {
            BanListDateRangePicker(chosenDateRange: $chosenDateRange, showDateSelectorSheet: $showDateSelectorSheet, banListDates: banListDates)
        }
    }
}

private func getYear(banListDate: String) -> String {
    return String(banListDate.split(separator: "-", maxSplits: 1)[0])
}

private struct BanListDateRangePicker: View {
    @State private var chosenYear: String
    @Binding private var chosenDateRange: Int
    @Binding private var showDateSelectorSheet: Bool
    
    private let banListDates: [BanListDate]
    
    private var banListEffectiveDatesByYear = [String:[String]]()
    private var banListEffectiveDatesByInd = [String:Int]()
    private let yearsSortedDesc: [String]
    private let numYears: Int
    
    init(chosenDateRange: Binding<Int>, showDateSelectorSheet: Binding<Bool>, banListDates: [BanListDate]) {
        _chosenYear = State(initialValue: getYear(banListDate: banListDates[chosenDateRange.wrappedValue].effectiveDate))
        self._chosenDateRange = chosenDateRange
        self._showDateSelectorSheet = showDateSelectorSheet
        self.banListDates = banListDates
        
        for (ind, banList) in banListDates.enumerated() {
            let banListDate = banList.effectiveDate
            banListEffectiveDatesByInd[banListDate] = ind
            banListEffectiveDatesByYear[getYear(banListDate: banListDate), default: [String]()].append(banListDate)
        }
        
        yearsSortedDesc = Array(banListEffectiveDatesByYear.keys).sorted(by: >)
        numYears = yearsSortedDesc.count
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text("Choose Ban List")
                    .font(.title2)
                    .bold()
                    .padding(.vertical)
                
                Text("Recent")
                    .font(.title3)
                Picker("List Year", selection: $chosenYear) {
                    ForEach(yearsSortedDesc[0 ..< numYears / 2], id: \.self) { year in
                        Text(year).tag(year)
                    }
                }
                .pickerStyle(.palette)
                
                Text("Older")
                    .font(.title3)
                Picker("List Year", selection: $chosenYear) {
                    ForEach(yearsSortedDesc[numYears / 2 ..< yearsSortedDesc.count], id: \.self) { year in
                        Text(year).tag(year)
                    }
                }
                .pickerStyle(.palette)
                .padding(.bottom)
            }
            .padding(.horizontal)
            
            ScrollView {
                LazyVStack {
                    ForEach(banListEffectiveDatesByYear[chosenYear]!, id: \.self) { year in
                        Button() {
                            chosenDateRange = banListEffectiveDatesByInd[year]!
                            showDateSelectorSheet = false
                        } label: {
                            HStack {
                                BanListDateRangeView(fromDate: year, toDate: (banListEffectiveDatesByInd[year] == 0) ? nil : banListDates[banListEffectiveDatesByInd[year]! - 1].effectiveDate)
                                Spacer()
                                Circle()
                                    .frame(width: 20, height: 20)
                                    .if(chosenDateRange == banListEffectiveDatesByInd[year]) {
                                        $0.foregroundColor(Color.accentColor)
                                    } else: {
                                        $0.foregroundColor(.secondary.opacity(0.7))
                                    }
                            }
                            .padding(.vertical, 5)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .frame(maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct BanListDateRangeView: View {
    let fromDate: String
    let toDate: String?
    
    var body: some View {
        HStack {
            ChosenBanListDateView(date: fromDate)
            Image(systemName: "arrowshape.right.fill")
                .foregroundColor(.primary)
            ChosenBanListDateView(date: toDate)
        }
    }
}


private struct ChosenBanListDateView: View {
    let date: String?
    
    var body: some View {
        if date != nil {
            InlineDateView(date: date!)
                .equatable()
        } else {
            Text("Present")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.primary)
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
                .font(.headline)
                .fontWeight(.bold)
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
        @State private var chosenFormat: BanListFormat = .tcg
        @State private var chosenDateRange: Int = 0
        @State private var banListDates = [BanListDate]()
        
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
        @State private var chosenFormat: BanListFormat = .tcg
        
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
        @State private var chosenFormat: BanListFormat = .tcg
        @State private var chosenDateRange: Int = 0
        @State private var banListDates = [BanListDate]()
        
        var body: some View {
            BanListDatesView(chosenFormat: $chosenFormat, chosenDateRange: $chosenDateRange, banListDates: $banListDates)
        }
    }
}
