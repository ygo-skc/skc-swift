//
//  Charts.swift
//  SKCSwift
//
//  Created by Javi Gomez on 3/2/25.
//

struct ChartData: Hashable {
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
