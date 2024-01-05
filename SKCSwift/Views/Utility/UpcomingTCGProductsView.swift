//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct UpcomingTCGProductsView: View {
    @Binding var canLoadNextView: Bool
    @Binding private var isDataInvalidated: Bool
    
    @State private var isDataLoaded = false
    @State private var events = [Event]()
    
    init(canLoadNextView: Binding<Bool>, isDataInvalidated: Binding<Bool> = .constant(false)) {
        self._canLoadNextView = canLoadNextView
        self._isDataInvalidated = isDataInvalidated
    }
    
    private func fetchData() {
        if !isDataLoaded || isDataInvalidated {
            request(url: upcomingEventsURL()) { (result: Result<Events, Error>) -> Void in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let upcomingProducts):
                        if self.events != upcomingProducts.events {
                            self.events = upcomingProducts.events
                        }
                        
                        self.isDataLoaded = true
                        self.isDataInvalidated = false
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    var body: some View {
        SectionView(header: "Upcoming products",
                    disableDestination: true,
                    variant: .plain,
                    destination: {EmptyView()},
                    content: {
            if !isDataLoaded {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 5) {
                    Text("TCG products that have been anounced and which we have a tenative release date for.")
                        .font(.body)
                        .padding(.bottom)
                    
                    ForEach(events, id: \.name) { event in
                        UpcomingTCGProduct(event: event)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    canLoadNextView = true
                }
            }
        })
        .onChange(of: $isDataInvalidated.wrappedValue, initial: true) {
            fetchData()
        }
    }
}


private struct UpcomingTCGProduct: View {
    var event: Event
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            DateBadgeView(date: event.eventDate, dateFormat: Dates.isoChicago, variant: .condensed)
            
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

struct UpcomingTCGProductsView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isDataLoaded = false
        
        UpcomingTCGProductsView(canLoadNextView: $isDataLoaded)
            .padding(.horizontal)
    }
}
