//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct UpcomingTCGProductsView: View, Equatable {
    let events: [Event]?
    
    var body: some View {
        SectionView(header: "Upcoming products",
                    variant: .plain,
                    content: {
            if let events {
                VStack(alignment: .leading, spacing: 5) {
                    Text("TCG products that have been announced and which we have a tentative release date for.")
                        .font(.body)
                        .padding(.bottom)
                    
                    ForEach(events, id: \.name) { event in
                        UpcomingTCGProductView(event: event)
                            .equatable()
                    }
                }
                .frame(maxWidth: .infinity)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        })
    }
}


private struct UpcomingTCGProductView: View, Equatable {
    var event: Event
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            DateBadgeView(date: event.eventDate, dateFormat: Date.isoChicago, variant: .condensed)
                .equatable()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(event.name)
                    .lineLimit(2)
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(LocalizedStringKey(event.notes))
                    .lineLimit(7)
                    .font(.body)
                
                Divider()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 5)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview() {
    UpcomingTCGProductsView(events: [Event(name: "Xyz", notes: "Yoooo", location: "", eventDate: "2024-08-23T05:00:00.000Z", url: "https://youtube.com")])
        .padding(.horizontal)
}
