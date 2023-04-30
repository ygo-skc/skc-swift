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
            LazyVStack(spacing: 5) {
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
                                    .lineLimit(2, reservesSpace: true)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Spacer()
                                DateView(date: "2022-01-01", variant: .condensed)
                            }
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity
                            )
                        }
                        Text("Description")
                            .font(.headline)
                            .fontWeight(.thin)
                        Text(LocalizedStringKey(event.notes))
                            .lineLimit(5)
                            .font(.body)
                        Divider()
                            .padding(.horizontal)
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