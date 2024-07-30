//
//  ContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/1/23.
//

import SwiftUI

struct ContentView: View, Equatable {
    private let screenWidth = UIScreen.main.bounds.width - 15
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                }
            BannedContent()
                .tabItem {
                    Image(systemName: "xmark.circle")
                }
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
        }
    }
}

struct CardSearchLinkDestination: View {
    var cardValue: CardValue
    
    var body: some View {
        CardView(cardID: cardValue.cardID)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(cardValue.cardName)
    }
}

struct CardInfo_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 30 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024)
}
