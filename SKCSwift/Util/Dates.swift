//
//  Dates.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/28/23.
//

import Foundation

func determineElapsedDaysSinceToday(reference: String) -> Int {
    let mostRecentProductReleaseDate = dateFormatter.date(from: reference)!
    let elapsedInterval = Date().timeIntervalSince(mostRecentProductReleaseDate)
    return Int(floor(elapsedInterval) / 60 / 60 / 24)
}
