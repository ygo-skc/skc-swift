//
//  Dates.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/28/23.
//

import Foundation

func determineElapsedDaysSinceToday(reference: String) -> Int {
    let referenceDate = Dates.yyyyMMdd_DateFormatter.date(from: reference)!
    let elapsedInterval = Date().timeIntervalSince(referenceDate)
    return Int(floor(elapsedInterval) / 60 / 60 / 24)
}

struct Dates {
    static let yyyyMMdd_DateFormatter = Dates.configure(format: "yyyy-MM-dd")
    static let iso_DateFormatter = Dates.configure(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
    
    /// Use this calendar object to work with Date objects without converting to devices Timezone. This would mean that the Date being used / retrieved from DB is also using GMT TimeZone.
    static let gmt_Calendar = {
        var c = Calendar.current
        c.timeZone = TimeZone(abbreviation: "GMT")!
        return c
    }()
    
    private static func configure(format: String) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = format
        f.timeZone = TimeZone(abbreviation: "UTC-5")
        return f
    }
}
