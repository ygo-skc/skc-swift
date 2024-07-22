//
//  Trending.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/22/24.
//

struct TrendingMetric: Codable {
    var resource: Card
    var occurrences: Int
    var change: Int
}

struct Trending: Codable {
    var resourceName: String
    var metrics: [TrendingMetric]
}
