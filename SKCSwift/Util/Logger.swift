//
//  Logger.swift
//  SKCSwift
//
//  Created by Javi Gomez on 8/1/26.
//

import Foundation
import os

nonisolated extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "SKCSwift"

    /// Network layer: `URLSession` data tasks and gRPC calls.
    static let network = Logger(subsystem: subsystem, category: "network")
    /// Settings screen: cache sizing and preferences.
    static let settings = Logger(subsystem: subsystem, category: "settings")
    /// View layer: model-parsing / rendering issues surfaced in the UI.
    static let ui = Logger(subsystem: subsystem, category: "ui")
}
