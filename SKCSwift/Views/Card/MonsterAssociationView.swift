//
//  MonsterAssociationView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import Foundation
import SwiftUI

private let ICON_SIZE = 30.0

struct MonsterAssociationView: View {
    var monsterAssociation: MonsterAssociation
    var attribute: Attribute
    
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

struct LevelAssociationView: View {
    var level: Int
    
    var body: some View {
        HStack {
            Image("card_level")
                .resizable()
                .frame(width: ICON_SIZE, height: ICON_SIZE)
            Text("x\(level)")
                .fontWeight(.semibold)
        }
    }
}

struct LevelAssociationViewModel_Previews: PreviewProvider {
    static var previews: some View {
        LevelAssociationView(level: 10)
    }
}

struct PendulumAssociationView: View {
    var pendScale: Int
    
    var body: some View {
        HStack {
            Image("pend_scale")
                .resizable()
                .frame(width: ICON_SIZE, height: ICON_SIZE)
            Text("x\(pendScale)")
                .fontWeight(.semibold)
        }
    }
}

struct RankAssociationView: View {
    var rank: Int
    
    var body: some View {
        HStack {
            Image("card_rank")
                .resizable()
                .frame(width: ICON_SIZE, height: ICON_SIZE)
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

struct PendulumAssociationView_Previews: PreviewProvider {
    static var previews: some View {
        PendulumAssociationView(pendScale: 4)
    }
}

struct LinkAssociationView: View {
    var linkRating: Int
    var linkArrows: String
    
    init(linkRating: Int, linkArrows: [String]) {
        self.linkRating = linkRating
        self.linkArrows = linkArrows.joined(separator: " ")
    }
    
    var body: some View {
        HStack {
            Text("L\(linkRating): \(linkArrows)")
                .fontWeight(.bold)
        }
    }
}

struct LinkAssociationViewModel_Previews: PreviewProvider {
    static var previews: some View {
        LinkAssociationView(linkRating: 4, linkArrows: ["↙️","↘️"])
    }
}
