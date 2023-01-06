//
//  LevelAssociationViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/5/23.
//

import SwiftUI

struct LevelAssociationViewModel: View {
    var level: Int
    
    let iconSize = 30.0
    
    var body: some View {
        HStack {
<<<<<<< HEAD
            Image("card_level")
                .resizable()
=======
            AsyncImage(url: URL(string: "https://thesupremekingscastle.com/assets/Light.svg"))
>>>>>>> master
                .frame(width: iconSize, height: iconSize)
                .cornerRadius(iconSize)
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
