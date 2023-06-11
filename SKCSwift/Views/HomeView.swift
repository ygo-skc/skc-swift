//
//  HomeViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct HomeView: View {
    let screenWidth = UIScreen.main.bounds.width - 10
    
    @State private var isTCGProductsInfoLoaded = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    DBStatsView()
                    CardOfTheDayView()
                    UpcomingTCGProducts(canLoadNextView: $isTCGProductsInfoLoaded)
                    
                    if isTCGProductsInfoLoaded {
                        YouTubeUploadsView()
                    }
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
