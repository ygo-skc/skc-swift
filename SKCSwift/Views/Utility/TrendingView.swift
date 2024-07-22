//
//  Trending.swift
//  SKCSwift
//
//  Created by Javi Gomez on 7/22/24.
//

import SwiftUI

struct TrendingView: View {
    @State private var trendingData = Trending(resourceName: "", metrics: [])
    @State private var isDataLoaded = false
    
    private func fetchData() {
        if isDataLoaded {
            return
        }
        
        request(url: trendingUrl(resource: .card)) { (result: Result<Trending, Error>) -> Void in
            DispatchQueue.main.async {
                switch result {
                case .success(let trending):
                    trendingData = trending
                    isDataLoaded = true
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    
    var body: some View {
        ForEach(trendingData.metrics, id: \.resource.cardID) { x in
            Text(x.resource.cardID)
        }
    }
}

#Preview {
    TrendingView()
}
