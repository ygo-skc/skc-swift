//
//  DateView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/7/23.
//

import SwiftUI


struct DateView: View {
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
                .frame(maxWidth: .infinity)
                .background(Color("pink_red"))
                .modifier(DateViewMonthModifier(variant: variant))
            Text(day)
                .padding(.top, -8)
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
                .font(.headline)
                .foregroundColor(Color(.white))
                .padding(.vertical, 0)
        case .condensed:
            content
                .font(.subheadline)
                .foregroundColor(Color(.white))
                .padding(.vertical, 0)
        }
    }
}

private struct DateViewDayModifier: ViewModifier {
    let variant: DateViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal:
            content
                .font(.title3)
                .fontWeight(.bold)
        case .condensed:
            content
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
        // Groups are needed as you can only have a max of 10 subviews, groups allow us to spread the views.
        
        DateView(date: "2022-01-31", variant: .condensed)
            .previewDisplayName("Condensed")
        
        Group {
            DateView(date: "2022-01-31")
                .previewDisplayName("January")
            DateView(date: "2022-02-18")
                .previewDisplayName("Febuary")
            DateView(date: "2022-03-18")
                .previewDisplayName("March")
            DateView(date: "2022-04-18")
                .previewDisplayName("April")
        }
        
        Group {
            DateView(date: "2022-05-18")
                .previewDisplayName("May")
            DateView(date: "2022-06-18")
                .previewDisplayName("June")
            DateView(date: "2022-07-18")
                .previewDisplayName("July")
            DateView(date: "2022-08-18")
                .previewDisplayName("August")
        }
        
        Group {
            DateView(date: "2022-09-18")
                .previewDisplayName("Septemeber")
            DateView(date: "2022-10-18")
                .previewDisplayName("October")
            DateView(date: "2022-11-18")
                .previewDisplayName("November")
            DateView(date: "2022-12-31")
                .previewDisplayName("December")
        }
        
        Group {
            DateView(date: "2022-09-18")
                .previewDisplayName("Dark Theme")
                .preferredColorScheme(.dark)
        }
    }
}
