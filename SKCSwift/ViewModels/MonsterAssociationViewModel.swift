//
//  MonsterAssociationViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import Foundation
import SwiftUI

struct MonsterAssociationViewModel: View {
    var level: Int
    let iconSize = 30.0
    let iconRadius = 30.0
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Spacer()
            HStack {
                AsyncImage(url: URL(string: "https://thesupremekingscastle.com/assets/Light.svg"))
                    .frame(width: iconSize, height: iconSize)
                    .cornerRadius(iconRadius)
                AsyncImage(url: URL(string: "https://thesupremekingscastle.com/assets/Light.svg"))
                    .frame(width: iconSize, height: iconSize)
                    .cornerRadius(iconRadius)
                Text("x\(level)")
                    .fontWeight(.semibold)
            }.padding(.vertical, 5.0).padding(.horizontal, 15).background(colorScheme == .light ? Color.white.opacity(0.85): Color.black.opacity(0.5)).cornerRadius(50.0)
            Spacer()
        }
    }
}

struct MonsterAssociationViewModel_Previews: PreviewProvider {
    static var previews: some View {
        MonsterAssociationViewModel(level: 10)
    }
}
