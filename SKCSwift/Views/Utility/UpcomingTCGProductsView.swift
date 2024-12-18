//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct UpcomingTCGProductsView: View {
    @Bindable var model: HomeViewModel
    
    var body: some View {
        SectionView(header: "Upcoming products",
                    variant: .plain,
                    content: {
            if let networkError = model.requestErrors["upcomingTCGProducts", default: nil] {
                NetworkErrorView(error: networkError, action: { Task { await model.fetchUpcomingTCGProducts() } })
            } else {
                VStack(alignment: .leading, spacing: 5) {
                    if let events = model.upcomingTCGProducts {
                        Text("TCG products that have been announced by Konami and of which we know the tentative date of.")
                            .font(.body)
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

#Preview {
    let model = HomeViewModel()
    UpcomingTCGProductsView(model: model)
}

#Preview {
    let model = HomeViewModel()
    UpcomingTCGProductsView(model: model)
        .task {
            await model.fetchUpcomingTCGProducts()
        }
}
