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
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 15)  {
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
            .modify {
                if #available(iOS 26.0, *) {
                    $0.buttonStyle(.glass)
                        .matchedTransitionSource(id: "ban-list-date-range", in: animation)
                } else {
                    $0.buttonStyle(.bordered)
                }
            }
            .tint(Color.accentColor.opacity(0.5))
            .foregroundColor(.black)
        }
        .popover(isPresented: $isSelectorSheetPresented) {
            BanListDateRangePicker(
                chosenDateRange: $dateRangeIndex,
                showDateSelectorSheet: $isSelectorSheetPresented,
                banListDates: dates
            )
            .navigationTransition(.zoom(sourceID: "ban-list-date-range", in: animation))
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
    private let recentYears: [String]
    private let olderYears: [String]?
    private let numYears: Int
    
    init(chosenDateRange: Binding<Int>,
         showDateSelectorSheet: Binding<Bool>,
         banListDates: [BanListDate]) {
        _chosenYear = State(initialValue: getYear(banListDate: banListDates[chosenDateRange.wrappedValue].effectiveDate))
        self._dateRangeIndex = chosenDateRange
        self._showDateSelectorSheet = showDateSelectorSheet
        self.dates = banListDates
        
        for (ind, banList) in banListDates.enumerated() {
            let banListDate = banList.effectiveDate
            banListEffectiveDatesByInd[banListDate] = ind
            banListEffectiveDatesByYear[getYear(banListDate: banListDate), default: [String]()].append(banListDate)
        }
        
        let yearsSortedDesc = Array(banListEffectiveDatesByYear.keys).sorted(by: >)
        numYears = yearsSortedDesc.count
        
        let initialOffset = numYears > 5 ? 5 : numYears - 1
        recentYears = Array(yearsSortedDesc[...initialOffset])
        if numYears > 5 {
            olderYears = Array(yearsSortedDesc[initialOffset...])
        } else {
            olderYears = nil
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Choose Ban List")
                    .font(.title2)
                    .bold()
                    .padding(.top)
                
                BanListYearPickerView(chosenYear: $chosenYear, name: "Recent", years: recentYears)
                if let olderYears {
                    BanListYearPickerView(chosenYear: $chosenYear, name: "Older", years: olderYears)
                }
                
                LazyVStack {
                    ForEach(banListEffectiveDatesByYear[chosenYear]!, id: \.self) { year in
                        Button() {
                            dateRangeIndex = banListEffectiveDatesByInd[year]!
                            showDateSelectorSheet = false
                        } label: {
                            HStack {
                                BanListDateRangeView(fromDate: year,
                                                     toDate: (banListEffectiveDatesByInd[year] == 0) ? nil : dates[banListEffectiveDatesByInd[year]! - 1].effectiveDate)
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
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .frame(maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal)
        }
    }
    
    private struct BanListYearPickerView: View {
        @Binding var chosenYear: String
        let name: String
        let years: [String]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(name)
                    .font(.headline)
                Picker("List Year", selection: $chosenYear) {
                    ForEach(years, id: \.self) { year in
                        Text(year).tag(year)
                    }
                }
                .pickerStyle(.palette)
            }
        }
    }
}

private struct BanListDateRangeView: View {
    let fromDate: String
    let toDate: String?
    
    var body: some View {
        HStack(spacing: 10) {
            ChosenBanListDateView(date: fromDate)
            Image(systemName: "arrowshape.right.fill")
                .foregroundColor(.accent)
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
