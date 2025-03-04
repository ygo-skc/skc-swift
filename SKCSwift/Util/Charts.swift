//
//  Charts.swift
//  SKCSwift
//
//  Created by Javi Gomez on 3/2/25.
//

import SwiftUI

struct ChartData: Hashable {
    let category: String
    let count: Int
    
    init(category: String, count: Int) {
        self.category = category
        self.count = count
    }
    
    static nonisolated func ranges(from data: [ChartData]) -> (Int, [(ChartData, ClosedRange<Int>)]) {
        var count = 0
        var ranges: [(ChartData, ClosedRange<Int>)] = []
        for d in data {
            ranges.append((d, count...(count+d.count)))
            count += d.count
        }
        return (count, ranges)
    }
}

struct Charts {
    static let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .brown,
                                  .cyan, .mint, .indigo, .teal, .synchroYGOCard, .dateRed, .effectYGOCard, .normalYGOCard, .fusionYGOCard]
    
    static nonisolated func determineChartColor(_ category: String) -> Color {
        let hashValue = abs(category.hash)
        let index = hashValue % Charts.colors.count
        return Charts.colors[index]
    }
    
    static nonisolated func sortChart(_ lhs: ChartData, _ rhs: ChartData) -> Bool {
        if lhs.count == rhs.count {
            return lhs.category < rhs.category
        }
        return lhs.count > rhs.count
    }
}
