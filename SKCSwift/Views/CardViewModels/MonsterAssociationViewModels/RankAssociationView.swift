//
//  RankAssociationViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct RankAssociationView: View {
    var rank: Int
    
    private static let ICON_SIZE = 30.0
    
    var body: some View {
        HStack {
            Image("card_rank")
                .resizable()
                .frame(width: RankAssociationView.ICON_SIZE, height: RankAssociationView.ICON_SIZE)
            Text("x\(rank)")
                .fontWeight(.semibold)
        }
    }
}

struct RankAssociationViewModel_Previews: PreviewProvider {
    static var previews: some View {
        RankAssociationView(rank: 4)
    }
}
