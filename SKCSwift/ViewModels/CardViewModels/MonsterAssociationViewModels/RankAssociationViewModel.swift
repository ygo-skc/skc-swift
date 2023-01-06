//
//  RankAssociationViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct RankAssociationViewModel: View {
    var rank: Int
    
    private static let ICON_SIZE = 30.0
    
    var body: some View {
        HStack {
            Image("card_rank")
                .resizable()
                .frame(width: RankAssociationViewModel.ICON_SIZE, height: RankAssociationViewModel.ICON_SIZE)
                .cornerRadius(RankAssociationViewModel.ICON_SIZE)
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
