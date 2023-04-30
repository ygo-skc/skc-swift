//
//  DateView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/7/23.
//

import SwiftUI

let dateFormatter = DateFormatter()

struct DateView: View {
    private var month: String
    private var day: String
    private var year: String
    private var variant: DateViewVariant
    
    init(date: String, variant: DateViewVariant = .normal) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.variant = variant
        
        let date = dateFormatter.date(from: date)!
        self.month = Calendar.current.shortMonthSymbols[Calendar.current.component(.month, from: date) - 1]
        self.day = String(Calendar.current.component(.day, from: date))
        self.year = String(Calendar.current.component(.year, from: date))
    }
    
    var body: some View {
        VStack {
            VStack {
                Text(month)
                    .modifier(DateViewMonthModifier(variant: variant))
            }
            .frame(maxWidth: .infinity)
            .background(Color("pink_red"))
            
            Text(day)
                .modifier(DateViewDayModifier(variant: variant))
            Text(year)
                .modifier(DateViewYearModifier(variant: variant))
        }
        .frame(width: (variant == .normal) ? 80 : 60)
        .background(Color("gray"))
        .cornerRadius((variant == .normal) ? 15 : 10)
    }
}

private struct DateViewMonthModifier: ViewModifier {
    var variant: DateViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal:
            content
                .font(.headline)
                .foregroundColor(Color(.white))
                .padding(.vertical, 1)
        case .condensed:
            content
                .font(.subheadline)
                .foregroundColor(Color(.white))
                .padding(.vertical, 1)
        }
    }
}

private struct DateViewDayModifier: ViewModifier {
    var variant: DateViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal:
            content
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top, -5)
        case .condensed:
            content
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.top, -5)
        }
    }
}

private struct DateViewYearModifier: ViewModifier {
    var variant: DateViewVariant
    
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
