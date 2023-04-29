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
                    destination: {EmptyView()},
                    content: {
            LazyVStack(alignment: .leading, spacing: 10) {
                Text("TCG products that have been anounced and which we have a tenative release date for.")
                    .font(.body)
                
                Spacer()
                
                if !isDataLoaded {
                    ProgressView()
                } else {
                    ForEach(events[..<5], id: \.name) { event in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(event.name)
                                    .lineLimit(2)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Spacer()
                                DateView(date: "2022-01-01")
                            }
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity
                            )
                        }
                        Text("Description")
                            .font(.headline)
                            .fontWeight(.medium)
                        Text(LocalizedStringKey(event.notes))
                            .lineLimit(5)
                            .font(.body)
                        Divider()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .onAppear {
                fetchData()
            }
        })
    }
}

struct UpcomingTCGProducts_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingTCGProducts()
    }
}
