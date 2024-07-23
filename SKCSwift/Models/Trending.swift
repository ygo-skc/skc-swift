//
//  Trending.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/22/24.
//

struct TrendingMetric<R:Codable>: Codable {
    var resource: R
    var occurrences: Int
    var change: Int
}

struct Trending<R:Codable>: Codable {
    var resourceName: TrendingResouceType
    var metrics: [TrendingMetric<R>]
}
