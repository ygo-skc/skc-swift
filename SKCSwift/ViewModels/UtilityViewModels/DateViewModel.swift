//
//  DateViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/7/23.
//

import SwiftUI

struct DateViewModel: View {
    private var month: String
    private var day: String
    private var year: String
    
    init(date: String) {
        let dateFormatter = DateFormatter()
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
                    .font(.subheadline)
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
                .font(.footnote)
        }.frame(width: 70)
            .background(Color("gray"))
            .cornerRadius(15)
        
    }
}

struct DateViewModel_Previews: PreviewProvider {
    static var previews: some View {
        DateViewModel(date: "2022-11-18")
    }
}
