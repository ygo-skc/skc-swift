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
    
    @Namespace private var formatAnimation
    @Namespace private var categoryAnimation
    
    private static let categories: [BannedContentCategory] = [.forbidden, .limited, .semiLimited]
    private static let formats: [CardRestrictionFormat] = [.tcg, .md, .genesys]
    
    @ViewBuilder
    private var formatView: some View {
        HStack(spacing: 15) {
            Text("Format")
                .font(.subheadline)
                .fontWeight(.regular)
            
            ForEach(RestrictedContentNavigatorView.formats, id: \.rawValue) { format in
                TabButton(selected: $format, value: format, animation: formatAnimation)
            }
        }
        .disabled(isDisabled)
    }
    
    @ViewBuilder
    private var category: some View {
        if format == .tcg || format == .md {
            HStack(spacing: 15) {
                Text("Category")
                    .font(.subheadline)
                    .fontWeight(.regular)
                
                ForEach(RestrictedContentNavigatorView.categories, id: \.rawValue) { category in
                    TabButton(selected: $contentCategory, value: category, animation: categoryAnimation)
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            formatView
            RestrictedContentDatesView(dateRangeIndex: $dateRangeIndex, dates: dates, isDisabled: isDisabled)
            category
        }
    }
}

private struct RestrictedContentDatesView: View {
    @Binding var dateRangeIndex: Int
    let dates: [BanListDate]
    let isDisabled: Bool
    
    @State private var isSelectorSheetPresented = false
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 15)  {
            Text("Range")
                .font(.subheadline)
                .fontWeight(.regular)
            
            Button() {
                isSelectorSheetPresented.toggle()
            } label: {
                if !dates.isEmpty {
                    RestrictedContentDateRangeView(fromDate: dates[dateRangeIndex].effectiveDate,
                                         toDate: (dateRangeIndex == 0) ? nil : dates[dateRangeIndex - 1].effectiveDate)
                }
            }
            .buttonStyle(.bordered)
            .disabled(isDisabled)
            .tint(Color.accentColor.opacity(0.5))
            .foregroundColor(.black)
            .matchedTransitionSource(id: "dates", in: animation)
            .popover(isPresented: $isSelectorSheetPresented) {
                RestrictedContentDateRangePicker(
                    chosenDateRange: $dateRangeIndex,
                    showDateSelectorSheet: $isSelectorSheetPresented,
                    dates: dates
                )
                .navigationTransition(.zoom(sourceID: "dates", in: animation))
            }
        }
    }
}

private struct RestrictedContentDateRangePicker: View {
    @State private var chosenYear: String
    @Binding private var dateRangeIndex: Int
    @Binding private var showDateSelectorSheet: Bool
    
    private let dates: [BanListDate]
    
    private var effectiveDatesByYear = [String:[String]]()
    private var effectiveDatesByInd = [String:Int]()
    private let recentYears: [String]
    private let olderYears: [String]?
    private let numYears: Int
    
    init(chosenDateRange: Binding<Int>,
         showDateSelectorSheet: Binding<Bool>,
         dates: [BanListDate]) {
        _chosenYear = State(initialValue: RestrictedContentDateRangePicker.getYear(date: dates[chosenDateRange.wrappedValue].effectiveDate))
        self._dateRangeIndex = chosenDateRange
        self._showDateSelectorSheet = showDateSelectorSheet
        self.dates = dates
        
        for (ind, restriction) in dates.enumerated() {
            let date = restriction.effectiveDate
            effectiveDatesByInd[date] = ind
            effectiveDatesByYear[RestrictedContentDateRangePicker.getYear(date: date), default: [String]()].append(date)
        }
        
        let yearsSortedDesc = Array(effectiveDatesByYear.keys).sorted(by: >)
        numYears = yearsSortedDesc.count
        
        let initialOffset = numYears > 5 ? 5 : numYears - 1
        recentYears = Array(yearsSortedDesc[...initialOffset])
        if numYears > 5 {
            olderYears = Array(yearsSortedDesc[(initialOffset + 1 )...])
        } else {
            olderYears = nil
        }
    }
    
    private static func getYear(date: String) -> String {
        return String(date.split(separator: "-", maxSplits: 1)[0])
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Choose Restriction Range")
                    .font(.title2)
                    .bold()
                    .padding(.top)
                
                RestrictedContentYearPicker(chosenYear: $chosenYear, name: "Recent", years: recentYears)
                if let olderYears {
                    RestrictedContentYearPicker(chosenYear: $chosenYear, name: "Older", years: olderYears)
                }
                
                if let effectiveDatesForYear = effectiveDatesByYear[chosenYear] {
                    ForEach(effectiveDatesForYear, id: \.self) { effectiveDate in
                        Button() {
                            dateRangeIndex = effectiveDatesByInd[effectiveDate] ?? 0
                            showDateSelectorSheet = false
                        } label: {
                            HStack {
                                RestrictedContentDateRangeView(fromDate: effectiveDate,
                                                     toDate: (effectiveDatesByInd[effectiveDate] == 0) ? nil : dates[effectiveDatesByInd[effectiveDate]! - 1].effectiveDate)
                                Spacer()
                                Circle()
                                    .frame(width: 20, height: 20)
                                    .if(dateRangeIndex == effectiveDatesByInd[effectiveDate]) {
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
                    ProgressView("Loading…")
                        .controlSize(.large)
                }
            }
            .presentationDetents([.medium])
            .modifier(.sheetParentView)
        }
    }
    
    private struct RestrictedContentYearPicker: View {
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

private struct RestrictedContentDateRangeView: View {
    let fromDate: Date
    let toDate: String?
    
    init(fromDate: String, toDate: String?) {
        let formatter = Date.yyyyMMddLocalFormatter
        self.fromDate = formatter.date(from: fromDate)!
        self.toDate = toDate
    }
    
    @ViewBuilder
    private var toDateView: some View {
        if toDate != nil {
            InlineDateView(date: toDate!)
                .equatable()
        } else {
            Text((fromDate > Date.now) ? "Unspecified" : "Present")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }
    
    var body: some View {
        HStack(spacing: 10) {
            InlineDateView(date: fromDate)
                .equatable()
            Image(systemName: "arrowshape.right.fill")
                .foregroundColor(.accent)
            toDateView
        }
    }
}
