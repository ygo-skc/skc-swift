//
//  MonsterAssociationView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/2/23.
//

import Foundation
import SwiftUI

private let ICON_SIZE = 30.0

struct MonsterAssociationView: View, Equatable {
    let monsterAssociation: MonsterAssociation?
    let attribute: Attribute
    let variant: YGOCardViewVariant
    let iconVariant: IconVariant
    
    init(monsterAssociation: MonsterAssociation? = nil, attribute: Attribute,
         variant: YGOCardViewVariant = .normal, iconVariant: IconVariant = .large) {
        self.monsterAssociation = monsterAssociation
        self.attribute = attribute
        self.variant = variant
        self.iconVariant = iconVariant
    }
    
    var body: some View {
        HStack {
            HStack {
                AttributeView(attribute: attribute, variant: iconVariant)
                    .equatable()
                
                if let level = monsterAssociation?.level {
                    LevelAssociationView(level: level, variant: iconVariant)
                } else if let rank = monsterAssociation?.rank {
                    RankAssociationView(rank: rank, variant: iconVariant)
                } else if let linkRating = monsterAssociation?.linkRating, let linkArrows = monsterAssociation?.linkArrows {
                    LinkAssociationView(linkRating: linkRating, linkArrows: linkArrows)
                }
                
                if let scaleRating = monsterAssociation?.scaleRating {
                    PendulumAssociationView(pendScale: scaleRating,variant: iconVariant)
                }
            }
            .modifier(MonsterAssociationViewModifier(variant: variant))
        }
    }
}

private struct MonsterAssociationViewModifier: ViewModifier {
    var variant: YGOCardViewVariant
    
    func body(content: Content) -> some View {
        switch(variant) {
        case .normal, .condensed:
            content
                .padding(.vertical, 5.0)
                .padding(.horizontal, 15)
                .background(.regularMaterial)
                .cornerRadius(50.0)
        case .listView:
            content
        }
    }
}

struct LevelAssociationView: View, Equatable {
    var level: UInt8
    var variant: IconVariant
    
    init(level: UInt8, variant: IconVariant = .large) {
        self.level = level
        self.variant = variant
    }
    
    var body: some View {
        HStack(spacing: 3) {
            Image(.level)
                .resizable()
                .modifier(IconViewModifier(variant: variant))
            Text("x\(level)")
                .fontWeight(.semibold)
        }
    }
}

private struct PendulumAssociationView: View, Equatable {
    var pendScale: UInt8
    var variant: IconVariant
    
    init(pendScale: UInt8, variant: IconVariant = .large) {
        self.pendScale = pendScale
        self.variant = variant
    }
    
    var body: some View {
        HStack(spacing: 3) {
            Image(.pendScale)
                .resizable()
                .modifier(IconViewModifier(variant: variant))
            Text("x\(pendScale)")
                .fontWeight(.semibold)
        }
    }
}

private struct RankAssociationView: View, Equatable {
    var rank: UInt8
    var variant: IconVariant
    
    init(rank: UInt8, variant: IconVariant = .large) {
        self.rank = rank
        self.variant = variant
    }
    
    var body: some View {
        HStack(spacing: 3) {
            Image(.rank)
                .resizable()
                .modifier(IconViewModifier(variant: variant))
            Text("x\(rank)")
                .fontWeight(.semibold)
        }
    }
}

private struct LinkAssociationView: View, Equatable {
    var linkRating: UInt8
    var linkArrows: String
    
    init(linkRating: UInt8, linkArrows: [String]) {
        self.linkRating = linkRating
        self.linkArrows = linkArrows.joined(separator: " ")
    }
    
    var body: some View {
        HStack {
            Text("L\(linkRating): \(linkArrows)")
                .fontWeight(.bold)
                .lineLimit(1)
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
