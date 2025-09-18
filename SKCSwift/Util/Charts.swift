//
//  Charts.swift
//  SKCSwift
//
//  Created by Javi Gomez on 3/2/25.
//

import SwiftUI

nonisolated struct ChartData: Hashable {
    let category: String
    let count: Int
    
    init(category: String, count: Int) {
        self.category = category
        self.count = count
    }
    
    static func ranges(from data: [ChartData]) -> (Int, [(ChartData, ClosedRange<Int>)]) {
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
    
    private static var colorCache: [String: Color] = ["Monster": .normalYGOCard, "Spell": .spellYGOCard, "Trap": .trapYGOCard,
                                       "Dark": .purple, "Light": .yellow, "Wind": .green, "Water": .blue, "Fire": .red, "Earth": .brown,
                                       "Normal": .normalYGOCard, "Effect": .effectYGOCard, "Ritual": .ritualYGOCard, "Fusion": .fusionYGOCard,
                                       "Synchro": .synchroYGOCard, "Xyz": .xyzYGOCard, "Link": .linkYGOCard, "Pendulum Normal": .normalYGOCard,
                                       "Pendulum Effect": .effectYGOCard, "Pendulum Fusion": .fusionYGOCard, "Pendulum Synchro": .synchroYGOCard,
                                       "Pendulum Xyz": .xyzYGOCard]
    
    static func determineChartColor(_ category: String) -> Color {
        if let cachedColor = colorCache[category] {
            return cachedColor
        }
        let hashValue = abs(category.hash) % 1000
        let index = hashValue % Charts.colors.count
        let color = Charts.colors[index]
        colorCache[category] = color
        return color
    }
    
    static func sortChart(_ lhs: ChartData, _ rhs: ChartData) -> Bool {
        if lhs.count == rhs.count {
            return lhs.category < rhs.category
        }
        return lhs.count > rhs.count
    }
}
