//
//  Dates.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/28/23.
//

import Foundation

enum ConversionFromSeconds: Double {
    case days = 86400, hours = 3600, minutes = 60, seconds = 1
}

struct Dates {
    static let yyyyMMddDateFormatter = configure(format: "yyyy-MM-dd")
    static let isoDateFormatter = configure(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
    
    /// Use this calendar object to work with Date objects without converting to devices Timezone. This would mean that the Date being used / retrieved from DB is also using GMT TimeZone.
    static let gmtCalendar = {
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

extension Date {
    func timeIntervalSinceNow(millisConversion: ConversionFromSeconds = .days) -> Int {
        let elapsedInterval = Date().timeIntervalSince(self)
        return Int(floor(elapsedInterval) / millisConversion.rawValue)
    }
}

extension String {
    func timeIntervalSinceNow(millisConversion: ConversionFromSeconds = .days) -> Int {
        let referenceDate = Dates.yyyyMMddDateFormatter.date(from: self)!
        return referenceDate.timeIntervalSinceNow(millisConversion: millisConversion)
    }
}
