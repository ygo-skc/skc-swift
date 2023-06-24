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
        return Color("normal")
    case "Effect":
        return Color("effect")
    case "Ritual":
        return Color("ritual")
    case "Fusion":
        return Color("fusion")
    case "Synchro":
        return Color("synchro")
    case "Xyz":
        return Color("xyz")
    case "Link":
        return Color("link")
    case "Spell":
        return Color("spell")
    case "Trap":
        return Color("trap")
    default:
        return .gray
    }
}

func cardColorGradient(cardColor: String) -> LinearGradient {
    switch cardColor {
    case "Pendulum-Normal":
        return LinearGradient(gradient: Gradient(stops: [Gradient.Stop(color: Color("normal"), location: 0.4), Gradient.Stop(color: Color("spell"), location: 0.6)]), startPoint: .top, endPoint: .bottom)
    case "Pendulum-Effect":
        return LinearGradient(gradient: Gradient(stops: [Gradient.Stop(color: Color("effect"), location: 0.4), Gradient.Stop(color: Color("spell"), location: 0.6)]), startPoint: .top, endPoint: .bottom)
    case "Pendulum-Ritual":
        return LinearGradient(gradient: Gradient(stops: [Gradient.Stop(color: Color("ritual"), location: 0.4), Gradient.Stop(color: Color("spell"), location: 0.6)]), startPoint: .top, endPoint: .bottom)
    case "Pendulum-Fusion":
        return LinearGradient(gradient: Gradient(stops: [Gradient.Stop(color: Color("fusion"), location: 0.4), Gradient.Stop(color: Color("spell"), location: 0.6)]), startPoint: .top, endPoint: .bottom)
    case "Pendulum-Synchro":
        return LinearGradient(gradient: Gradient(stops: [Gradient.Stop(color: Color("synchro"), location: 0.4), Gradient.Stop(color: Color("spell"), location: 0.6)]), startPoint: .top, endPoint: .bottom)
    case "Pendulum-Xyz":
        return LinearGradient(gradient: Gradient(stops: [Gradient.Stop(color: Color("xyz"), location: 0.4), Gradient.Stop(color: Color("spell"), location: 0.6)]), startPoint: .top, endPoint: .bottom)
    default:
        return LinearGradient(gradient: Gradient(colors: [.white, .white]), startPoint: .top, endPoint: .bottom)
    }
}
