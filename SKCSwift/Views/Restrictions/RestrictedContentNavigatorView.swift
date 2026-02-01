//
//  RestrictedContentNavigatorView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct RestrictedContentNavigatorView: View {
    @Binding var format: CardRestrictionFormat
    @Binding var dateRangeIndex: Int
    @Binding var contentCategory: BannedContentCategory
    
    let dates: [BanListDate]
    let isDisabled: Bool    // bubbling up since disabling the parent causes issues w/ popover in iOS 18
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RestrictedContentFormatsView(format: $format)
                .disabled(isDisabled)
            RestrictedContentDatesView(dateRangeIndex: $dateRangeIndex, dates: dates, isDisabled: isDisabled)
            if format == .tcg || format == .md {
                BannedContentCategoryView(contentCategory: $contentCategory)
                    .disabled(isDisabled)
            }
        }
    }
    
    private struct RestrictedContentFormatsView: View {
        @Binding var format: CardRestrictionFormat
        @Namespace private var animation
        
        private static let formats: [CardRestrictionFormat] = [.tcg, .md, .genesys]
        
        var body: some View {
            HStack(spacing: 15) {
                Text("Format")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ForEach(RestrictedContentFormatsView.formats, id: \.rawValue) { format in
                    TabButton(selected: $format, value: format, animation: animation)
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
    
    private struct BannedContentCategoryView: View {
        @Binding var contentCategory: BannedContentCategory
        @Namespace private var animation
        
        private static let categories: [BannedContentCategory] = [.forbidden, .limited, .semiLimited]
        
        var body: some View {
            HStack(spacing: 15) {
                Text("Category")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ForEach(BannedContentCategoryView.categories, id: \.rawValue) { category in
                    TabButton(selected: $contentCategory, value: category, animation: animation)
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}

struct RestrictedContentDatesView: View {
    @Binding var dateRangeIndex: Int
    let dates: [BanListDate]
    let isDisabled: Bool
    
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
            .buttonStyle(.bordered)
            .disabled(isDisabled)
            .tint(Color.accentColor.opacity(0.5))
            .foregroundColor(.black)
            .matchedTransitionSource(id: "dates", in: animation)
            .popover(isPresented: $isSelectorSheetPresented) {
                BanListDateRangePicker(
                    chosenDateRange: $dateRangeIndex,
                    showDateSelectorSheet: $isSelectorSheetPresented,
                    banListDates: dates
                )
                .navigationTransition(.zoom(sourceID: "dates", in: animation))
            }
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
            olderYears = Array(yearsSortedDesc[(initialOffset + 1 )...])
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
                
                if let effectiveDatesForYear = banListEffectiveDatesByYear[chosenYear] {
                    ForEach(effectiveDatesForYear, id: \.self) { effectiveDate in
                        Button() {
                            dateRangeIndex = banListEffectiveDatesByInd[effectiveDate] ?? 0
                            showDateSelectorSheet = false
                        } label: {
                            HStack {
                                BanListDateRangeView(fromDate: effectiveDate,
                                                     toDate: (banListEffectiveDatesByInd[effectiveDate] == 0) ? nil : dates[banListEffectiveDatesByInd[effectiveDate]! - 1].effectiveDate)
                                Spacer()
                                Circle()
                                    .frame(width: 20, height: 20)
                                    .if(dateRangeIndex == banListEffectiveDatesByInd[effectiveDate]) {
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
                } else {
                    ProgressView("Loading...")
                        .controlSize(.large)
                }
            }
            .presentationDetents([.medium])
            .modifier(.sheetParentView)
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
