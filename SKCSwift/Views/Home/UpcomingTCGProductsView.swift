//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct UpcomingTCGProductsView: View, Equatable {
    static func == (lhs: UpcomingTCGProductsView, rhs: UpcomingTCGProductsView) -> Bool {
        lhs.events == rhs.events && lhs.isDataLoaded == rhs.isDataLoaded && lhs.networkError == rhs.networkError
    }
    
    let events: [Event]
    let isDataLoaded: Bool
    let networkError: NetworkError?
    let retryCB: () async -> Void
    
    var body: some View {
        SectionView(header: "Upcoming products",
                    variant: .plain,
                    content: {
            VStack(alignment: .leading, spacing: 5) {
                if let networkError {
                    NetworkErrorView(error: networkError, action: { Task { await retryCB() } })
                } else {
                    if isDataLoaded || !events.isEmpty {
                        Text("TCG products that have been announced by Konami and of which we know the tentative date of.")
                            .font(.callout)
                            .padding(.bottom)
                        
                        ForEach(events, id: \.name) { event in
                            UpcomingTCGProductView(event: event)
                                .equatable()
                        }
                    }
                    else {
                        ProgressView("Loading...")
                            .controlSize(.large)
                    }
                }
            }
            .frame(maxWidth: .infinity)
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

#Preview("Default") {
    UpcomingTCGProductsView(events: [], isDataLoaded: true, networkError: nil, retryCB: {})
        .padding(.horizontal)
}

#Preview("Loading") {
    UpcomingTCGProductsView(events: [], isDataLoaded: false, networkError: nil, retryCB: {})
        .padding(.horizontal)
}

#Preview("Network Error") {
    UpcomingTCGProductsView(events: [], isDataLoaded: true, networkError: .timeout, retryCB: {})
        .padding(.horizontal)
}

