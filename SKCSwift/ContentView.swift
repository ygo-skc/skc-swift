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
            Tab("Home", systemImage: "house") {
                HomeView()
            }
//            Tab("Ban Lists", systemImage: "x.square") {
//                BannedContent()
//            }
            Tab("Browse", systemImage: "square.grid.2x2") {
                BrowseView()
            }
            Tab(role: .search) {
                SearchView()
            }
        }
    }
}

struct CardInfo_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
