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
        return .red
    case "Limited", "Limited 1":
        return .yellow
    case "Semi-Limited", "Limited 2":
        return .green
    case "Limited 3":
        return .blue
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
    case "Fusion":
        return Color("fusion")
    case "Ritual":
        return Color("ritual")
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
