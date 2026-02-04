//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct UpcomingTCGProductsView: View, Equatable {
    static func == (lhs: UpcomingTCGProductsView, rhs: UpcomingTCGProductsView) -> Bool {
        lhs.events == rhs.events
        && lhs.dataTaskStatus == rhs.dataTaskStatus
    }
    
    let events: [Event]
    let dataTaskStatus: DataTaskStatus
    let networkError: NetworkError?
    let retryCB: () async -> Void
    
    @ViewBuilder
    private var upcomingTCGProducts: some View {
        Text("TCG products that have been announced by Konami and of which we know the tentative date of.")
            .font(.callout)
            .padding(.bottom)
        
        ForEach(events, id: \.name) { event in
            UpcomingTCGProductView(event: event)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Upcoming products")
                .modifier(.headerText)
            
            if let networkError {
                NetworkErrorView(error: networkError, action: { Task { await retryCB() } })
            } else if dataTaskStatus == .done || !events.isEmpty {
                upcomingTCGProducts
            } else {
                HStack {
                    ProgressView("Loading...")
                        .controlSize(.large)
                }
                .padding(.top)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct UpcomingTCGProductView: View {
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
    UpcomingTCGProductsView(events: [],
                            dataTaskStatus: .done,
                            networkError: nil,
                            retryCB: {})
    .padding(.horizontal)
}

#Preview("Loading") {
    UpcomingTCGProductsView(events: [],
                            dataTaskStatus: .pending,
                            networkError: nil,
                            retryCB: {})
    .padding(.horizontal)
}

#Preview("Network Error") {
    UpcomingTCGProductsView(events: [],
                            dataTaskStatus: .error,
                            networkError: .timeout,
                            retryCB: {})
    .padding(.horizontal)
}

