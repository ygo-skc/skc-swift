//
//  RestrictionDatesView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 9/10/25.
//

import SwiftUI

struct RestrictionDatesView: View {
    @Binding var dateRangeIndex: Int
    let dates: [BanListDate]
    
    @State private var isSelectorSheetPresented = false
    
    var body: some View {
        HStack(spacing: 20)  {
            Text("Range")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Button() {
                isSelectorSheetPresented.toggle()
            } label: {
                if !dates.isEmpty {
                    BanListDateRangeView(fromDate: dates[dateRangeIndex].effectiveDate,
                                         toDate: (dateRangeIndex == 0) ? nil : dates[dateRangeIndex - 1].effectiveDate)
                }
            }
            .buttonStyle(.bordered)
            .tint(Color.accentColor.opacity(0.5))
            .foregroundColor(.black)
        }
        .popover(isPresented: $isSelectorSheetPresented) {
            BanListDateRangePicker(
                chosenDateRange: $dateRangeIndex,
                showDateSelectorSheet: $isSelectorSheetPresented,
                banListDates: dates
            )
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private func getYear(banListDate: String) -> String {
    return String(banListDate.split(separator: "-", maxSplits: 1)[0])
}

private struct BanListDateRangePicker: View {
    @State private var chosenYear: String
    @Binding private var dateRangeIndex: Int
    @Binding private var showDateSelectorSheet: Bool
    
    private let dates: [BanListDate]
    
    private var banListEffectiveDatesByYear = [String:[String]]()
    private var banListEffectiveDatesByInd = [String:Int]()
    private let yearsSortedDesc: [String]
    private let numYears: Int
    
    init(chosenDateRange: Binding<Int>, showDateSelectorSheet: Binding<Bool>, banListDates: [BanListDate]) {
        _chosenYear = State(initialValue: getYear(banListDate: banListDates[chosenDateRange.wrappedValue].effectiveDate))
        self._dateRangeIndex = chosenDateRange
        self._showDateSelectorSheet = showDateSelectorSheet
        self.dates = banListDates
        
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
                            dateRangeIndex = banListEffectiveDatesByInd[year]!
                            showDateSelectorSheet = false
                        } label: {
                            HStack {
                                BanListDateRangeView(fromDate: year, toDate: (banListEffectiveDatesByInd[year] == 0) ? nil : dates[banListEffectiveDatesByInd[year]! - 1].effectiveDate)
                                Spacer()
                                Circle()
                                    .frame(width: 20, height: 20)
                                    .if(dateRangeIndex == banListEffectiveDatesByInd[year]) {
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
