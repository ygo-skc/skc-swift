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
                    Text("Content").fontWeight(.bold)
                        .font(.title2)
                    Text("The SKC Database has 1,000 cards, 36 ban lists and 200 products.").fontWeight(.regular)
                        .font(.headline)
                }
            }.navigationTitle("Home")
        }
    }
}

struct HomeViewModel_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewModel()
    }
}
