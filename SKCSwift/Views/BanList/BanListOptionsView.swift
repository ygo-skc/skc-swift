//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct BanListOptionsView: View {
    @Bindable var model: BannedContentViewModel
    
    var body: some View {
        VStack {
            BanListFormatsView(chosenFormat: $model.chosenFormat)
            BanListDatesView(model: model)
        }
    }
}

private struct BanListDatesView: View {
    @Bindable var model: BannedContentViewModel
    
    var body: some View {
        HStack {
            Text("Range")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.trailing)
            
            Button() {
                model.showDateSelectorSheet.toggle()
            } label: {
                if let banListDates = model.banListDates, !banListDates.isEmpty {
                    BanListDateRangeView(fromDate: banListDates[model.chosenDateRange].effectiveDate,
                                         toDate: (model.chosenDateRange == 0) ? nil : banListDates[model.chosenDateRange - 1].effectiveDate)
                }
            }
            .buttonStyle(.bordered)
            .tint(Color.accentColor)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
        }
        .onChange(of: $model.chosenFormat.wrappedValue, initial: true) {
            Task {
                // TODO: can this be improved?
                await model.fetchBanListDates()
            }
        }
        .popover(isPresented: $model.showDateSelectorSheet) {
            BanListDateRangePicker(chosenDateRange: $model.chosenDateRange, showDateSelectorSheet: $model.showDateSelectorSheet, banListDates: model.banListDates ?? [])
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

