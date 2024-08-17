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
                    Image(systemName: "x.square")
                }
            BrowseView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                }
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
        }
    }
}

struct CardInfo_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 30 * 1024 * 1024, diskCapacity: 50 * 1024 * 1024)
}
