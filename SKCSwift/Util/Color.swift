//
//  Colors.swift
//  SKCSwift
//
//  Created by Javi Gomez on 1/17/23.
//

import SwiftUI

func banStatusColor(status: String) -> Color {
    switch status {
    case "Forbidden":
        return Color("forbidden")
    case "Limited", "Limited 1":
        return Color("limited")
    case "Semi-Limited", "Limited 2":
        return Color("semi-limited")
    case "Limited 3":
        return Color("limited-three")
    default:
        return .gray
    }
}

func cardColorUI(cardColor: String) -> Color {
    switch cardColor {
    case "Normal":
        return Color("normal_ygo_card")
    case "Effect":
        return Color("effect_ygo_card")
    case "Ritual":
        return Color("ritual_ygo_card")
    case "Fusion":
        return Color("fusion_ygo_card")
    case "Synchro":
        return Color("synchro_ygo_card")
    case "Xyz":
        return Color("xyz_ygo_card")
    case "Link":
        return Color("link_ygo_card")
    case "Spell":
        return Color("spell_ygo_card")
    case "Trap":
        return Color("trap_ygo_card")
    default:
        return .gray
    }
}

func cardColorGradient(cardColor: String) -> LinearGradient {
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
