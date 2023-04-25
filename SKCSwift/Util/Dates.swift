//
//  Dates.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/28/23.
//

import Foundation

func determineElapsedDaysSinceToday(reference: String) -> Int {
    let referenceDate = dateFormatter.date(from: reference)!
    let elapsedInterval = Date().timeIntervalSince(referenceDate)
    return Int(floor(elapsedInterval) / 60 / 60 / 24)
}
