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

private struct LevelAssociationView: View {
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

private struct PendulumAssociationView: View {
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

private struct RankAssociationView: View {
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

private struct LinkAssociationView: View {
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

#Preview("Monster Association") {
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

#Preview("Level Association") {
    LevelAssociationView(level: 10)
}

#Preview("Rank Association") {
    RankAssociationView(rank: 4)
}

#Preview("Pendulum Association") {
    PendulumAssociationView(pendScale: 4)
}

#Preview("Link Association") {
    LinkAssociationView(linkRating: 4, linkArrows: ["↙️","↘️"])
}
