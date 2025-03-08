//
//  OneDBarChart.swift
//  SKCSwift
//
//  Created by Javi Gomez on 3/2/25.
//

import SwiftUI
import Charts

struct OneDBarChartView: View {
    @State private var selectedValue: Double? = nil
    @State private var selectedDataPoint: ChartData?
    
    private let data: [ChartData]
    private let ranges: [(ChartData, ClosedRange<Int>)]
    private let total: Int
    private let cornerRadius = 10.0
    
    nonisolated private func clipShape(_ d: ChartData) -> some Shape {
        if data.count == 1 {
            return UnevenRoundedRectangle(topLeadingRadius: cornerRadius, bottomLeadingRadius: cornerRadius, bottomTrailingRadius: cornerRadius, topTrailingRadius: cornerRadius, style: .continuous)
        } else if d == data.first {
            return UnevenRoundedRectangle(topLeadingRadius: cornerRadius, bottomLeadingRadius: cornerRadius, bottomTrailingRadius: 0, topTrailingRadius: 0, style: .continuous)
        } else if d == data.last {
            return UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: cornerRadius, topTrailingRadius: cornerRadius, style: .continuous)
        } else {
            return UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 0, style: .continuous)
        }
    }
    
    init(data: [ChartData]) {
        self.data = data.sorted(by: Charts.sortChart)
        (total, ranges) = ChartData.ranges(from: self.data)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Chart(data, id: \.category) { dataElement in
                BarMark(x: .value("Occurrences", dataElement.count))
                    .foregroundStyle(Charts.determineChartColor(dataElement.category))
                    .opacity(selectedDataPoint == nil ? 1 :
                                dataElement.category == selectedDataPoint?.category ? 1 : 0.4)
                    .clipShape(clipShape(dataElement))
                    .annotation(position: .automatic,
                                spacing: 0,
                                overflowResolution: .init(x: .fit, y: .disabled)) {
                        if dataElement.category == selectedDataPoint?.category {
                            GroupBox() {
                                Text(dataElement.category)
                                    .font(.headline)
                                Text("\(dataElement.count)/\(total)")
                                    .font(.subheadline)
                            }
                            .padding(.bottom)
                        }
                    }
            }
            .chartXAxis(.hidden)
            .chartLegend(.hidden)
            .chartXSelection(value: $selectedValue)
            .frame(height: 35)
            .onChange(of: selectedValue) { _, newValue in
                if let newValue {
                    let selected = Int(ceil(newValue))
                    for (cd, range) in ranges {
                        if range.contains(selected) {
                            selectedDataPoint = cd
                            break
                        }
                    }
                } else {
                    selectedDataPoint = nil
                }
            }
            
            ChartLegend(data: data, selectedDataPoint: selectedDataPoint)
                .equatable()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .dynamicTypeSize(...DynamicTypeSize.medium)
    }
}

#Preview("Default") {
    OneDBarChartView(data: [.init(category: "Rare", count: 7),
                            .init(category: "Ultra Rare", count: 4),
                            .init(category: "Super Rare", count: 10),
                            .init(category: "Ultra Pharaoh Rare", count: 1),
                            .init(category: "Secret Pharaoh Rare", count: 1)])
    .padding(.horizontal)
}

#Preview("One Data Point") {
    OneDBarChartView(data: [.init(category: "Rare", count: 1)])
        .padding(.horizontal)
}

#Preview("Two Equal Data Point") {
    OneDBarChartView(data: [.init(category: "Rare", count: 1), .init(category: "Super Rare", count: 1)])
        .padding(.horizontal)
}
