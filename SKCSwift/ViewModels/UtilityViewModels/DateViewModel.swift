//
//  DateViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/7/23.
//

import SwiftUI

let dateFormatter = DateFormatter()

struct DateViewModel: View {
    private var month: String
    private var day: String
    private var year: String
    
    init(date: String) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let date = dateFormatter.date(from: date)!
        self.month = Calendar.current.shortMonthSymbols[Calendar.current.component(.month, from: date) - 1]
        self.day = String(Calendar.current.component(.day, from: date))
        self.year = String(Calendar.current.component(.year, from: date))
    }
    
    var body: some View {
        VStack {
            VStack {
                Text(month)
                    .font(.headline)
                    .foregroundColor(Color(.white))
                    .padding(.vertical, 3)
            }
            .frame(maxWidth: .infinity)
            .background(Color("pink_red"))
            
            Text(day)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top, -5)
            Text(year)
                .font(.callout)
        }.frame(width: 80)
            .background(Color("gray"))
            .cornerRadius(15)
        
    }
}

struct DateViewModel_Previews: PreviewProvider {
    static var previews: some View {
        // Groups are needed as you can only have a max of 10 subviews, groups allow us to spread the views.
        Group {
            DateViewModel(date: "2022-01-31")
                .previewDisplayName("January")
            DateViewModel(date: "2022-02-18")
                .previewDisplayName("Febuary")
            DateViewModel(date: "2022-03-18")
                .previewDisplayName("March")
            DateViewModel(date: "2022-04-18")
                .previewDisplayName("April")
        }
        
        Group {
            DateViewModel(date: "2022-05-18")
                .previewDisplayName("May")
            DateViewModel(date: "2022-06-18")
                .previewDisplayName("June")
            DateViewModel(date: "2022-07-18")
                .previewDisplayName("July")
            DateViewModel(date: "2022-08-18")
                .previewDisplayName("August")
        }
        
        Group {
            DateViewModel(date: "2022-09-18")
                .previewDisplayName("Septemeber")
            DateViewModel(date: "2022-10-18")
                .previewDisplayName("October")
            DateViewModel(date: "2022-11-18")
                .previewDisplayName("November")
            DateViewModel(date: "2022-12-31")
                .previewDisplayName("December")
        }
        
        Group {
            DateViewModel(date: "2022-09-18")
                .previewDisplayName("Dark Theme")
                .preferredColorScheme(.dark)
        }
    }
}
