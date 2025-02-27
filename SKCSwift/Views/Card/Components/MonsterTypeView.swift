//
//  MonsterTypeView.swift
//  SKCSwift
//
//  Created by Javi Gomez on 2/26/25.
//

import SwiftUI

struct MonsterTypeView: View {
    let img: Image
    let variant: IconVariant
    
    init(monsterType: MonsterType, variant: IconVariant = .large) {
        img = (monsterType == .unknown) ? Image(systemName: "questionmark.circle.fill") : Image(monsterType.rawValue.lowercased())
        self.variant = variant
    }
    
    var body: some View {
        img
            .resizable()
            .modifier(IconViewModifier(variant: variant))
    }
}

#Preview("Aqua") {
    MonsterTypeView(monsterType: .aqua)
}

#Preview("Beast Warrior") {
    MonsterTypeView(monsterType: .beastWarrior)
}

#Preview("Beast") {
    MonsterTypeView(monsterType: .beast)
}

#Preview("Cyberse") {
    MonsterTypeView(monsterType: .cyberse)
}

#Preview("Dinosaur") {
    MonsterTypeView(monsterType: .dinosaur)
}

#Preview("Divine Beast") {
    MonsterTypeView(monsterType: .divineBeast)
}

#Preview("Dragon") {
    MonsterTypeView(monsterType: .dragon)
}

#Preview("Fairy") {
    MonsterTypeView(monsterType: .fairy)
}

#Preview("Fiend") {
    MonsterTypeView(monsterType: .fiend)
}

#Preview("Fish") {
    MonsterTypeView(monsterType: .fish)
}

#Preview("Illusion") {
    MonsterTypeView(monsterType: .illusion)
}

#Preview("Insect") {
    MonsterTypeView(monsterType: .insect)
}

#Preview("Machine") {
    MonsterTypeView(monsterType: .machine)
}

#Preview("Plant") {
    MonsterTypeView(monsterType: .plant)
}

#Preview("Psychic") {
    MonsterTypeView(monsterType: .psychic)
}

#Preview("Pyro") {
    MonsterTypeView(monsterType: .pyro)
}

#Preview("Reptile") {
    MonsterTypeView(monsterType: .reptile)
}

#Preview("Rock") {
    MonsterTypeView(monsterType: .rock)
}

#Preview("Sea Serpent") {
    MonsterTypeView(monsterType: .seaSerpent)
}

#Preview("Spellcaster") {
    MonsterTypeView(monsterType: .spellcaster)
}

#Preview("Thunder") {
    MonsterTypeView(monsterType: .thunder)
}

#Preview("Warrior") {
    MonsterTypeView(monsterType: .warrior)
}

#Preview("Winged Beast") {
    MonsterTypeView(monsterType: .wingedBeast)
}

#Preview("Wyrm") {
    MonsterTypeView(monsterType: .wyrm)
}

#Preview("Zombie") {
    MonsterTypeView(monsterType: .zombie)
}
