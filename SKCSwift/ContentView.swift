//
//  ContentView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/1/23.
//

import SwiftUI

struct ContentView: View {
    private let screenWidth = UIScreen.main.bounds.width - 15
    
    var body: some View {
        TabView {
            HomeViewModel().tabItem{
                Image(systemName: "house")
            }
            CardSearchViewModel().tabItem{
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
