//
//  ContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/1/23.
//

import SwiftUI

struct ContentView: View, Equatable {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }
            Tab("Ban Lists", systemImage: "x.square") {
                BanListContentView()
            }
            Tab("Browse", systemImage: "square.grid.2x2") {
                BrowseView()
            }
            Tab(role: .search) {
                SearchView()
            }
        }
        .modify {
            if #available(iOS 26.0, *) {
                $0.tabBarMinimizeBehavior(.onScrollDown)
            }
        }
    }
}

struct CardInfo_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
