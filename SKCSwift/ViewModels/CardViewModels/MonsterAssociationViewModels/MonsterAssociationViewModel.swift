//
//  MonsterAssociationViewModel.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import Foundation
import SwiftUI

struct MonsterAssociationViewModel: View {
    var monsterAssociation: MonsterAssociation
    var attribute: Attribute
    
    private static let ICON_SIZE = 30.0
    
    var body: some View {
        HStack {
            Spacer()
            HStack {
                AttributeViewModel(attribute: attribute)
                
                if (monsterAssociation.level != nil) {
                    LevelAssociationViewModel(level: monsterAssociation.level!)
                } else if (monsterAssociation.rank != nil) {
                    RankAssociationViewModel(rank: monsterAssociation.rank!)
                }
            }.padding(.vertical, 5.0).padding(.horizontal, 15).background(Color("TranslucentBackground")).cornerRadius(50.0)
            Spacer()
        }
    }
}

struct MonsterAssociationViewModel_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MonsterAssociationViewModel(monsterAssociation: MonsterAssociation(level: 10), attribute: Attribute(rawValue: "Light")!)
            MonsterAssociationViewModel(monsterAssociation: MonsterAssociation(level: 1), attribute: Attribute(rawValue: "Dark")!)
            MonsterAssociationViewModel(monsterAssociation: MonsterAssociation(level: 2), attribute: Attribute(rawValue: "Wind")!)
            MonsterAssociationViewModel(monsterAssociation: MonsterAssociation(level: 3), attribute: Attribute(rawValue: "Earth")!)
            MonsterAssociationViewModel(monsterAssociation: MonsterAssociation(level: 4), attribute: Attribute(rawValue: "Water")!)
            MonsterAssociationViewModel(monsterAssociation: MonsterAssociation(level: 4), attribute: Attribute(rawValue: "Fire")!)
            
            MonsterAssociationViewModel(monsterAssociation: MonsterAssociation(rank: 4), attribute: Attribute(rawValue: "Fire")!)
        }
    }
}
