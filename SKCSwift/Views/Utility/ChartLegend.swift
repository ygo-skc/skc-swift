//
//  ChartLegend.swift
//  SKCSwift
//
//  Created by Javi Gomez on 3/3/25.
//

import SwiftUI
import Charts

struct ChartLegend: View, Equatable {
    private let data: [ChartData]
    private let selectedDataPoint: ChartData?
    
    init(data: [ChartData], selectedDataPoint: ChartData?) {
        self.data = data
        self.selectedDataPoint = selectedDataPoint
    }
    
    var body: some View {
        FlowLayout {
            ForEach(data.map { $0.category }, id: \.self) { category in
                HStack {
                    BasicChartSymbolShape.circle
                        .foregroundColor(Charts.determineChartColor(category))
                        .frame(width: 8, height: 8)
                    Text(category)
                        .font(.caption)
                }
                .opacity(selectedDataPoint == nil ? 1 :
                            category == selectedDataPoint?.category ? 1 : 0.4)
            }
        }
    }
}

#Preview {
    ChartLegend(data: [.init(category: "Rare", count: 7),
                       .init(category: "Ultra Rare", count: 4),
                       .init(category: "Super Rare", count: 10),
                       .init(category: "Ultra Pharaoh Rare", count: 1),
                       .init(category: "Secret Pharaoh Rare", count: 1)],
                selectedDataPoint: nil)
}
