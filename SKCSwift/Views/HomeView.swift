//
//  HomeViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct HomeView: View {
    let screenWidth = UIScreen.main.bounds.width - 10
    
    var body: some View {
        NavigationStack {
            ScrollView {
                SectionView(header: "Content",
                            disableDestination: true,
                            destination: {EmptyView()},
                            content: {DBStatsView()})
                .padding(.top)
                
                CardOfTheDayView()
                    .padding(.top)
            }
            .padding(.horizontal)
            .navigationTitle("Home")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
