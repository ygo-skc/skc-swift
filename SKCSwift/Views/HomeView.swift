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
                SectionView(header: "Content") {
                    VStack {
                        Text("All data is provided by a collection of API's/DB's designed to provide the best Yu-Gi-Oh! information")
                            .font(.body)
                        
                        Text("DB Stats")
                            .font(.title2)
                            .padding(.vertical, 2)
                        HStack {
                            DBStatView(count: "10,993", stat: "Cards")
                                .padding(.horizontal)
                            DBStatView(count: "47", stat: "Ban Lists")
                                .padding(.horizontal)
                            DBStatView(count: "285", stat: "Products")
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.top)
                
                CardOfTheDayView()
                    .padding(.top)
            }
            .padding(.horizontal)
            .navigationTitle("Home")
        }
    }
}

struct DBStatView: View {
    var count: String
    var stat: String
    
    var body: some View {
        VStack {
            Text(count)
                .font(.title3)
            Text(stat)
                .font(.headline)
                .fontWeight(.heavy)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
