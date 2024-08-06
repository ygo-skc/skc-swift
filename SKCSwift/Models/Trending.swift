//
//  Trending.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/22/24.
//

struct TrendingMetric<R:Codable>: Codable {
    let resource: R
    let occurrences: Int
    let change: Int
}

struct Trending<R:Codable>: Codable {
    let resourceName: TrendingResouceType
    let metrics: [TrendingMetric<R>]
}
