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
    
    @State private var selectedValue: Double? = nil
    @State private var selectedDataPoint: ChartData?
    
    private let ranges: [(ChartData, ClosedRange<Int>)]
    private let total: Int
    private let cornerRadius = 10.0
    
    private func clipShape(_ d: ChartData) -> some Shape {
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
        self.data = data.sorted { $0.count > $1.count }
        (total, ranges) = ChartData.ranges(from: self.data)
    }
    
    var body: some View {
        Chart(data, id: \.category) { d in
            BarMark(x: .value("Occurrences", d.count))
                .foregroundStyle(by: .value("name", d.category))
                .opacity(d.category == selectedDataPoint?.category ? 1 : 0.6)
                .clipShape(clipShape(d))
                .annotation(position: .automatic,
                            spacing: 0,
                            overflowResolution: .init(x: .fit, y: .disabled)) {
                    if d.category == selectedDataPoint?.category {
                        GroupBox() {
                            Text(d.category)
                                .font(.headline)
                            Text("\(d.count)/\(total)")
                                .font(.subheadline)
                        }
                        .padding(.bottom)
                        .dynamicTypeSize(...DynamicTypeSize.medium)
                    }
                }
        }
        .chartXAxis(.hidden)
        .chartLegend(.hidden)
        .chartXSelection(value: $selectedValue)
        .frame(height: 30)
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
    OneDBarChartView(data: [.init(category: "Rare", count: 7)])
        .padding(.horizontal)
}

#Preview("Two Equal Data Point") {
    OneDBarChartView(data: [.init(category: "Rare", count: 1), .init(category: "Super Rare", count: 1)])
        .padding(.horizontal)
}
