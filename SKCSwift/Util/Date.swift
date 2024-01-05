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
    static let yyyyMMddGMT = (formatter: gmtFormatter(format: "yyyy-MM-dd", abbreviation: "GMT"), calendar: gmtCalendar)
    static let isoChicago = (formatter: tzFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", identifier: "America/Chicago"), calendar: chicagoCalendar)
    
    /// Use this calendar object to work with Date objects without converting to devices Timezone. This would mean that the Date being used / retrieved from DB is also using GMT TimeZone.
    static let gmtCalendar = {
        var c = Calendar.current
        c.timeZone = TimeZone(abbreviation: "GMT")!
        return c
    }()
    
    static let chicagoCalendar = {
        var c = Calendar.current
        c.timeZone = TimeZone(identifier: "America/Chicago")!
        return c
    }()
    
    private static func gmtFormatter(format: String, abbreviation: String) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = format
        f.timeZone = TimeZone(abbreviation: abbreviation)
        return f
    }
    
    private static func tzFormatter(format: String, identifier: String) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = format
        f.timeZone = TimeZone(identifier: identifier)
        return f
    }
}

extension Date {
    func timeIntervalSinceNow(millisConversion: ConversionFromSeconds = .days) -> Int {
        let elapsedInterval = Date().timeIntervalSince(self)
        return Int(floor(elapsedInterval) / millisConversion.rawValue)
    }
    
    func getMonthDayAndYear(calendar: Calendar) -> (String, String, String){
        return (calendar.shortMonthSymbols[calendar.component(.month, from: self) - 1], String(calendar.component(.day, from: self)), String(calendar.component(.year, from: self)))
    }
}

extension String {
    func timeIntervalSinceNow(millisConversion: ConversionFromSeconds = .days) -> Int {
        let referenceDate = Dates.yyyyMMddGMT.formatter.date(from: self)!
        return referenceDate.timeIntervalSinceNow(millisConversion: millisConversion)
    }
}
