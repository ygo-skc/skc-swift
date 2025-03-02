//
//  OneDBarChart.swift
//  SKCSwift
//
//  Created by Javi Gomez on 3/2/25.
//

import SwiftUI
import Charts

struct OneDBarChartView: View {
    let data: [ChartData]
    
    @State private var selectedValue: Int? = nil
    @State private var selectedDataPoint: ChartData?
    @State private var previousSelectedRange: ClosedRange<Int>?
    
    private let ranges: [(ChartData, ClosedRange<Int>)]
    private let total: Int
    private let cornerRadius = 10.0
    
    init(data: [ChartData]) {
        self.data = data.sorted { $0.count > $1.count }
        (total, ranges) = ChartData.ranges(from: self.data)
    }
    
    var body: some View {
        Chart(data, id: \.category) { d in
            BarMark(x: .value("Occurrences", d.count))
                .foregroundStyle(by: .value("name", d.category))
                .opacity(d.category == selectedDataPoint?.category ? 1 : 0.6)
                .annotation(position: .automatic,
                            spacing: 0,
                            overflowResolution: .init(x: .fit, y: .disabled)) {
                    if d.category == selectedDataPoint?.category {
                        GroupBox() {
                            Text(d.category)
                                .font(.headline)
                            Text(String(d.count))
                                .font(.subheadline)
                        }
                        .padding(.bottom)
                        .dynamicTypeSize(...DynamicTypeSize.medium)
                    }
                }
                .clipShape(
                    d == data.last
                    ? UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: cornerRadius, topTrailingRadius: cornerRadius, style: .continuous)
                    : d == data.first
                    ? UnevenRoundedRectangle(topLeadingRadius: cornerRadius, bottomLeadingRadius: cornerRadius, bottomTrailingRadius: 0, topTrailingRadius: 0, style: .continuous)
                    : UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 0, style: .continuous)
                )
        }
        .chartXAxis(.hidden)
        .chartXSelection(value: $selectedValue)
        .frame(height: 50)
        .scaledToFit()
        .onChange(of: selectedValue) { _, newValue in
            if let newValue {
                if previousSelectedRange?.contains(newValue) != true {
                    for (cd, range) in ranges {
                        if range.contains(newValue) {
                            selectedDataPoint = cd
                            self.previousSelectedRange = range
                            break
                        }
                    }
                }
            } else {
                selectedDataPoint = nil
                previousSelectedRange = nil
            }
        }
    }
}

#Preview {
    OneDBarChartView(data: [.init(category: "Rare", count: 7),
                        .init(category: "Ultra Rare", count: 4),
                        .init(category: "Super Rare", count: 10)])
    .padding(.horizontal)
}
