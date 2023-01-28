//
//  HomeViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct HomeViewModel: View {
    let screenWidth = UIScreen.main.bounds.width - 10
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Content")
                        .font(.title)
                    Text("The SKC Database has 1,000 cards, 36 ban lists and 200 products.")
                        .fontWeight(.light)
                        .font(.headline)
                }
                .padding(.top)
            }
            .padding(.horizontal)
            .navigationTitle("Home")
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .topLeading
            )
        }
    }
}

struct HomeViewModel_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewModel()
    }
}
