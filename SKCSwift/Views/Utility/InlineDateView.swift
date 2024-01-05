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
    
    init(date: String, dateFormat: (formatter: DateFormatter, calendar: Calendar) = Dates.yyyyMMddGMT) {
        let date = dateFormat.formatter.date(from: date)!
        (self.month, self.day, self.year) = date.getMonthDayAndYear(calendar: dateFormat.calendar)
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

#Preview("Inline") {
    InlineDateView(date: "2022-01-31")
}
