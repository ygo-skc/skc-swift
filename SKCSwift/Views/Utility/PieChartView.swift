//
//  ChartView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 2/7/25.
//

import SwiftUI
import Charts

struct ChartData: Hashable {
    private(set) var category: String
    private(set) var count: Int
    
    init(name: String, count: Int) {
        self.category = name
        self.count = count
    }
}

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
    let data: [ChartData]
    let dataTitle: String
    
    @State private var selectedAngle: Double?
    @State private var selectedDataPoint: ChartData?
    @State private var previousRange: ClosedRange<Int>?
    
    private var ranges: [(ChartData, ClosedRange<Int>)] = []
    private var total: Int
    
    private var selectedCategory: String {
        return selectedDataPoint != nil ? selectedDataPoint!.category : "Total"
    }
    
    private var selectedTotal: String {
        return selectedDataPoint != nil ? "\(selectedDataPoint!.count)/\(total)" : "\(total)"
    }
    
    init(data: [ChartData], dataTitle: String) {
        self.data = data.sorted { $0.count > $1.count }
        self.dataTitle = dataTitle
        
        var count = 0
        for d in self.data {
            ranges.append((d, count...(count+d.count)))
            count += d.count
        }
        total = count
    }
    
    
    var body: some View {
        Chart(data, id: \.category) { element in
            SectorMark(
                angle: .value("Count", element.count),
                innerRadius: .ratio(0.618),
                angularInset: 1.5
            )
            .cornerRadius(5)
            .foregroundStyle(by: .value("name", element.category))
            .opacity(element.category == selectedDataPoint?.category ? 1 : 0.6)
        }
        .scaledToFit()
        .chartLegend(alignment: .leading, spacing: 8)
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
        .onChange(of: selectedAngle) { oldValue, newValue in
            if let newValue {
                let angle = Int(ceil(newValue))
                
                if previousRange?.contains(angle) != true {
                    for (cd, range) in ranges {
                        if range.contains(angle) {
                            selectedDataPoint = cd
                            self.previousRange = range
                            break
                        }
                    }
                }
            } else {
                selectedDataPoint = nil
                previousRange = nil
            }
        }
        .padding(.horizontal)
    }
}
