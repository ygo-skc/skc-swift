//
//  ContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/1/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }
            Tab("Restrictions", systemImage: "x.square") {
                RestrictedContentView()
            }
            Tab("Browse", systemImage: "square.grid.2x2") {
                BrowseView()
            }
            Tab("Trending", systemImage: "flame") {
                TrendingView()
            }
            Tab(role: .search) {
                SearchView()
            }
        }
        .modify {
            if #available(iOS 26.0, *) {
                $0.tabBarMinimizeBehavior(.onScrollDown)
            } else {
                $0
            }
        }
    }
}

#Preview {
    ContentView()
}
