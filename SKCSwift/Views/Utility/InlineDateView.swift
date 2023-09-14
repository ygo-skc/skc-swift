//
//  InlineDateView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/1/23.
//

import SwiftUI

struct InlineDateView: View {
    private let month: String
    private let day: String
    private let year: String
    
    init(date: String, formatter: DateFormatter = Dates.yyyyMMddDateFormatter) {
        let date = formatter.date(from: date)!
        
        self.month = Dates.gmtCalendar.shortMonthSymbols[Calendar.current.component(.month, from: date) - 1]
        self.day = String(Dates.gmtCalendar.component(.day, from: date))
        self.year = String(Dates.gmtCalendar.component(.year, from: date))
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(month)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(Color("pink_red"))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color(.white))
            Group {
                Text("\(day), ")
                    .fontWeight(.semibold)
                + Text(year)
            }
            .font(.caption2)
            .foregroundColor(.primary)
            .padding(.horizontal, 8)
        }
        .background(.gray.opacity(0.2))
        .cornerRadius(8)
    }
}

struct InlineDateView_Previews: PreviewProvider {
    static var previews: some View {
        InlineDateView(date: "2022-01-31")
            .previewDisplayName("Inline")
    }
}
