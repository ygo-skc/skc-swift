//
//  LevelAssociationViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct LevelAssociationViewModel: View {
    var level: Int
    
    private static let ICON_SIZE = 30.0
    
    var body: some View {
        HStack {
            Image("card_level")
                .resizable()
                .frame(width: LevelAssociationViewModel.ICON_SIZE, height: LevelAssociationViewModel.ICON_SIZE)
            Text("x\(level)")
                .fontWeight(.semibold)
        }
    }
}

struct LevelAssociationViewModel_Previews: PreviewProvider {
    static var previews: some View {
        LevelAssociationViewModel(level: 10)
    }
}
