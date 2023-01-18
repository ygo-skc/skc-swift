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
