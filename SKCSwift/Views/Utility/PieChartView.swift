//
//  ChartView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 2/7/25.
//

import SwiftUI
import Charts

struct PieChartGroupView: View {
    let description: String
    let dataTitle: String
    let data: [ChartData]
    
    var body: some View {
        GroupBox(label: Label(dataTitle, systemImage: "chart.pie.fill").foregroundColor(.accentColor).padding(.bottom)) {
            Text(LocalizedStringKey(description))
                .font(.headline)
            Divider()
                .padding(.bottom)
            PieChartView(data: data, dataTitle: dataTitle)
        }
        .padding(.bottom)
        .groupBoxStyle(.listItem)
    }
}

struct PieChartView: View {
    @State private var selectedAngle: Double?
    @State private var selectedDataPoint: ChartData?
    
    private let data: [ChartData]
    private let dataTitle: String
    private let ranges: [(ChartData, ClosedRange<Int>)]
    private let total: Int
    
    private var selectedCategory: String {
        return selectedDataPoint != nil ? selectedDataPoint!.category : "Total"
    }
    
    private var selectedTotal: String {
        return selectedDataPoint != nil ? "\(selectedDataPoint!.count)/\(total)" : "\(total)"
    }
    
    init(data: [ChartData], dataTitle: String) {
        self.data = data.sorted { $0.count > $1.count }
        self.dataTitle = dataTitle
        (total, ranges) = ChartData.ranges(from: self.data)
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Chart(data, id: \.category) { dataPoint in
                SectorMark(
                    angle: .value("Count", dataPoint.count),
                    innerRadius: .ratio(0.618),
                    angularInset: 1.5
                )
                .cornerRadius(5)
                .foregroundStyle(Charts.determineChartColor(dataPoint.category))
                .opacity(selectedDataPoint == nil ? 1 :
                            dataPoint.category == selectedDataPoint?.category ? 1 : 0.4)
            }
            .scaledToFit()
            .chartLegend(.hidden)
            .chartAngleSelection(value: $selectedAngle)
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    let frame = geometry[chartProxy.plotFrame!]
                    VStack {
                        Text(selectedCategory)
                            .font(.headline)
                            .fontWeight(.medium)
                        Text(selectedTotal)
                            .font(.subheadline)
                    }
                    .position(x: frame.midX, y: frame.midY)
                }
            }
            .onChange(of: selectedAngle) { _, newValue in
                if let newValue {
                    let angle = Int(ceil(newValue))
                    
                    for (cd, range) in ranges {
                        if range.contains(angle) {
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
                .padding(.top)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .dynamicTypeSize(...DynamicTypeSize.medium)
    }
}
