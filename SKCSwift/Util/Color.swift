//
//  Colors.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/17/23.
//

import SwiftUI

nonisolated func banStatusColor(status: String) -> Color {
    switch status {
    case "Forbidden":
        return .forbidden
    case "Limited", "Limited 1":
        return .limited
    case "Semi-Limited", "Limited 2":
        return .semiLimited
    case "Limited 3":
        return .limitedThree
    default:
        return .gray
    }
}

nonisolated func cardColorUI(cardColor: String) -> Color {
    switch cardColor {
    case "Normal":
        return .normalYGOCard
    case "Effect":
        return .effectYGOCard
    case "Ritual":
        return .ritualYGOCard
    case "Fusion":
        return .fusionYGOCard
    case "Synchro":
        return .synchroYGOCard
    case "Xyz":
        return .xyzYGOCard
    case "Link":
        return .linkYGOCard
    case "Spell":
        return .spellYGOCard
    case "Trap":
        return .trapYGOCard
    default:
        return .gray
    }
}

nonisolated func cardColorGradient(cardColor: String) -> LinearGradient {
    switch cardColor {
    case "Pendulum-Normal":
        return LinearGradient(gradient: Gradient(stops: [Gradient.Stop(color: cardColorUI(cardColor: "Normal"), location: 0.4), Gradient.Stop(color: cardColorUI(cardColor: "Spell"), location: 0.6)]), startPoint: .top, endPoint: .bottom)
    case "Pendulum-Effect":
        return LinearGradient(gradient: Gradient(stops: [Gradient.Stop(color: cardColorUI(cardColor: "Effect"), location: 0.4), Gradient.Stop(color: cardColorUI(cardColor: "Spell"), location: 0.6)]), startPoint: .top, endPoint: .bottom)
    case "Pendulum-Ritual":
        return LinearGradient(gradient: Gradient(stops: [Gradient.Stop(color: cardColorUI(cardColor: "Ritual"), location: 0.4), Gradient.Stop(color: cardColorUI(cardColor: "Spell"), location: 0.6)]), startPoint: .top, endPoint: .bottom)
    case "Pendulum-Fusion":
        return LinearGradient(gradient: Gradient(stops: [Gradient.Stop(color: cardColorUI(cardColor: "Fusion"), location: 0.4), Gradient.Stop(color: cardColorUI(cardColor: "Spell"), location: 0.6)]), startPoint: .top, endPoint: .bottom)
    case "Pendulum-Synchro":
        return LinearGradient(gradient: Gradient(stops: [Gradient.Stop(color: cardColorUI(cardColor: "Synchro"), location: 0.4), Gradient.Stop(color: cardColorUI(cardColor: "Spell"), location: 0.6)]), startPoint: .top, endPoint: .bottom)
    case "Pendulum-Xyz":
        return LinearGradient(gradient: Gradient(stops: [Gradient.Stop(color: cardColorUI(cardColor: "Xyz"), location: 0.4), Gradient.Stop(color: cardColorUI(cardColor: "Spell"), location: 0.6)]), startPoint: .top, endPoint: .bottom)
    default:
        return LinearGradient(gradient: Gradient(colors: [.white, .white]), startPoint: .top, endPoint: .bottom)
    }
}
