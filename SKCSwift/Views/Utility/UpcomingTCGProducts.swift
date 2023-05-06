//
//  DBStatsView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 4/26/23.
//

import SwiftUI

struct UpcomingTCGProducts: View {
    @State private(set) var events = [Event]()
    @State private(set) var isDataLoaded = false
    
    func fetchData() {
        if isDataLoaded {
            return
        }
        
        request(url: upcomingEventsURL()) { (result: Result<Events, Error>) -> Void in
            DispatchQueue.main.async {
                switch result {
                case .success(let upcomingProducts):
                    self.events = upcomingProducts.events
                    self.isDataLoaded = true
                case .failure(let error):
                    print(error)
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
            VStack(alignment: .leading, spacing: 5) {
                Text("TCG products that have been anounced and which we have a tenative release date for.")
                    .font(.body)
                    .padding(.bottom)
                
                if !isDataLoaded {
                    ProgressView()
                } else {
                    ForEach(events, id: \.name) { event in
                        HStack(alignment: .top, spacing: 20) {
                            DateView(date: event.eventDate, formatter: Dates.iso_DateFormatter, variant: .condensed)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(event.name)
                                    .lineLimit(2)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(LocalizedStringKey(event.notes))
                                    .lineLimit(7)
                                    .font(.body)
                            }
                        }
                        Divider()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .onAppear {
                fetchData()
            }
        })
    }
}

struct UpcomingTCGProducts_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingTCGProducts()
            .padding(.horizontal)
    }
}
