//
//  MonsterAssociationView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import Foundation
import SwiftUI

struct MonsterAssociationView: View {
    var monsterAssociation: MonsterAssociation
    var attribute: Attribute
    
    private static let ICON_SIZE = 30.0
    
    var body: some View {
        HStack {
            Spacer()
            HStack {
                AttributeView(attribute: attribute)
                
                if (monsterAssociation.level != nil) {
                    LevelAssociationView(level: monsterAssociation.level!)
                    if (monsterAssociation.scaleRating != nil) {
                        PendulumAssociationView(pendScale: monsterAssociation.scaleRating!)
                    }
                } else if (monsterAssociation.rank != nil) {
                    RankAssociationView(rank: monsterAssociation.rank!)
                } else if (monsterAssociation.linkRating != nil && monsterAssociation.linkArrows != nil) {
                    LinkAssociationView(linkRating: monsterAssociation.linkRating!, linkArrows: monsterAssociation.linkArrows!)
                }
            }
            .padding(.vertical, 5.0)
            .padding(.horizontal, 15)
            .background(Color("translucent_background"))
            .cornerRadius(50.0)
            Spacer()
        }
    }
}

struct MonsterAssociationView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MonsterAssociationView(monsterAssociation: MonsterAssociation(level: 10), attribute: Attribute(rawValue: "Light")!)
            MonsterAssociationView(monsterAssociation: MonsterAssociation(level: 1), attribute: Attribute(rawValue: "Dark")!)
            MonsterAssociationView(monsterAssociation: MonsterAssociation(level: 2), attribute: Attribute(rawValue: "Wind")!)
            MonsterAssociationView(monsterAssociation: MonsterAssociation(level: 3), attribute: Attribute(rawValue: "Earth")!)
            MonsterAssociationView(monsterAssociation: MonsterAssociation(level: 4), attribute: Attribute(rawValue: "Water")!)
            MonsterAssociationView(monsterAssociation: MonsterAssociation(level: 4), attribute: Attribute(rawValue: "Fire")!)
            
            MonsterAssociationView(monsterAssociation: MonsterAssociation(rank: 4), attribute: Attribute(rawValue: "Fire")!)
            
            MonsterAssociationView(monsterAssociation: MonsterAssociation(level: 4, scaleRating: 10), attribute: Attribute(rawValue: "Water")!)
            
            MonsterAssociationView(monsterAssociation: MonsterAssociation(linkRating: 4, linkArrows: ["↙️", "⬇️", "↘️", "⬆️"]), attribute: Attribute(rawValue: "Fire")!)
        }
    }
}
