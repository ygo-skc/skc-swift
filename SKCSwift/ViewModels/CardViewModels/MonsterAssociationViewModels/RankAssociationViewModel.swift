//
//  RankAssociationViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct RankAssociationViewModel: View {
    var rank: Int
    
    let iconSize = 30.0
    
    var body: some View {
        HStack {
            Image("card_rank")
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .cornerRadius(iconSize)
            Text("x\(rank)")
                .fontWeight(.semibold)
        }
    }
}

struct RankAssociationViewModel_Previews: PreviewProvider {
    static var previews: some View {
        RankAssociationViewModel(rank: 4)
    }
}
