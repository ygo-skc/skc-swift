//
//  DateView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/7/23.
//

import SwiftUI


struct CalendarDateView: View {
    private let month: String
    private let day: String
    private let year: String
    private let variant: DateViewVariant
    
    init(date: String, formatter: DateFormatter = Dates.yyyyMMddDateFormatter, variant: DateViewVariant = .normal) {
        self.variant = variant
        
        let date = formatter.date(from: date)!
        
        self.month = Dates.gmtCalendar.shortMonthSymbols[Calendar.current.component(.month, from: date) - 1]
        self.day = String(Dates.gmtCalendar.component(.day, from: date))
        self.year = String(Dates.gmtCalendar.component(.year, from: date))
    }
    
    var body: some View {
        VStack {
            Text(month)
                .modifier(DateViewMonthModifier(variant: variant))
            Text(day)
                .modifier(DateViewDayModifier(variant: variant))
            Text(year)
                .modifier(DateViewYearModifier(variant: variant))
        }
        .background(Color("gray"))
        .modifier(DateViewParentModifier(variant: variant))
    }
}

private struct DateViewParentModifier: ViewModifier {
    let variant: DateViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal:
            content
                .frame(width: 80)
                .cornerRadius(15)
        case .condensed:
            content
                .frame(width: 60)
                .cornerRadius(10)
        }
    }
}

private struct DateViewMonthModifier: ViewModifier {
    let variant: DateViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal:
            content
                .frame(maxWidth: .infinity)
                .background(Color("pink_red"))
                .font(.headline)
                .foregroundColor(Color(.white))
        case .condensed:
            content
                .frame(maxWidth: .infinity)
                .background(Color("pink_red"))
                .font(.subheadline)
                .foregroundColor(Color(.white))
        }
    }
}

private struct DateViewDayModifier: ViewModifier {
    let variant: DateViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal:
            content
                .padding(.top, -8)
                .font(.title3)
                .fontWeight(.bold)
        case .condensed:
            content
                .padding(.top, -8)
                .font(.subheadline)
                .fontWeight(.bold)
        }
    }
}

private struct DateViewYearModifier: ViewModifier {
    let variant: DateViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal:
            content
                .font(.callout)
        case .condensed:
            content
                .font(.footnote)
        }
    }
}

struct DateView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDateView(date: "2022-01-31", variant: .condensed)
            .previewDisplayName("Condensed")
        
        Group {
            CalendarDateView(date: "2022-01-31")
                .previewDisplayName("January")
            CalendarDateView(date: "2022-02-18")
                .previewDisplayName("Febuary")
            CalendarDateView(date: "2022-03-18")
                .previewDisplayName("March")
            CalendarDateView(date: "2022-04-18")
                .previewDisplayName("April")
        }
        
        Group {
            CalendarDateView(date: "2022-05-18")
                .previewDisplayName("May")
            CalendarDateView(date: "2022-06-18")
                .previewDisplayName("June")
            CalendarDateView(date: "2022-07-18")
                .previewDisplayName("July")
            CalendarDateView(date: "2022-08-18")
                .previewDisplayName("August")
        }
        
        Group {
            CalendarDateView(date: "2022-09-18")
                .previewDisplayName("Septemeber")
            CalendarDateView(date: "2022-10-18")
                .previewDisplayName("October")
            CalendarDateView(date: "2022-11-18")
                .previewDisplayName("November")
            CalendarDateView(date: "2022-12-31")
                .previewDisplayName("December")
        }
        
        Group {
            CalendarDateView(date: "2022-09-18")
                .previewDisplayName("Dark Theme")
                .preferredColorScheme(.dark)
        }
    }
}
