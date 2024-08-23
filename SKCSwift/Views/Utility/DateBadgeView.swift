//
//  DateView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/7/23.
//

import SwiftUI


struct DateBadgeView: View, Equatable {
    private let month: String
    private let day: String
    private let year: String
    private let variant: DateBadgeViewVariant
    
    init(date: String, dateFormat: (formatter: DateFormatter, calendar: Calendar) = Date.yyyyMMddGMT, variant: DateBadgeViewVariant = .normal) {
        self.variant = variant
        
        let date = dateFormat.formatter.date(from: date)!
        (self.month, self.day, self.year) = date.getMonthDayAndYear(calendar: dateFormat.calendar)
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
        .background(.dateGray)
        .modifier(DateViewParentModifier(variant: variant))
    }
}

private struct DateViewParentModifier: ViewModifier {
    let variant: DateBadgeViewVariant
    
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
    let variant: DateBadgeViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal:
            content
                .frame(maxWidth: .infinity)
                .background(.dateRed)
                .font(.headline)
                .foregroundColor(Color(.white))
        case .condensed:
            content
                .frame(maxWidth: .infinity)
                .background(.dateRed)
                .font(.subheadline)
                .foregroundColor(Color(.white))
        }
    }
}

private struct DateViewDayModifier: ViewModifier {
    let variant: DateBadgeViewVariant
    
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
    let variant: DateBadgeViewVariant
    
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


#Preview("Condensed") {
    DateBadgeView(date: "2022-01-31", variant: .condensed)
}

#Preview("Jan") {
    DateBadgeView(date: "2022-01-01")
}

#Preview("Feb") {
    DateBadgeView(date: "2022-02-01")
}

#Preview("Mar") {
    DateBadgeView(date: "2022-03-18")
}

#Preview("Apr") {
    DateBadgeView(date: "2022-04-18")
}

#Preview("May") {
    DateBadgeView(date: "2022-05-18")
}

#Preview("Jun") {
    DateBadgeView(date: "2022-06-18")
}

#Preview("Jul") {
    DateBadgeView(date: "2022-07-18")
}

#Preview("Aug") {
    DateBadgeView(date: "2022-08-18")
}

#Preview("Sept") {
    DateBadgeView(date: "2022-09-18")
}

#Preview("Oct") {
    DateBadgeView(date: "2022-10-18")
}

#Preview("Nov") {
    DateBadgeView(date: "2022-11-18")
}

#Preview("Dec") {
    DateBadgeView(date: "2022-12-18")
}

#Preview("Dark Theme") {
    DateBadgeView(date: "2022-09-18")
        .preferredColorScheme(.dark)
}

