//
//  CardScore.swift
//  SKCSwift
//
//  Created by Javi Gomez on 10/25/25.
//

public nonisolated struct CardScore: Codable, Equatable {
    public let currentScoreByFormat: [String: UInt32]
    public let uniqueFormats: [String]
    public let scheduledChanges: [String]
    
    init(currentScoreByFormat: [String: UInt32], uniqueFormats: [String], scheduledChanges: [String]) {
        self.currentScoreByFormat = currentScoreByFormat
        self.uniqueFormats = uniqueFormats
        self.scheduledChanges = scheduledChanges
    }
}

extension CardScore {
    nonisolated static func rpcParser(currentScoreByFormat: [String: UInt32], uniqueFormats: [String], scheduledChanges: [String]) -> Self {
        return .init(currentScoreByFormat: currentScoreByFormat,
                     uniqueFormats: uniqueFormats,
                     scheduledChanges: scheduledChanges)
    }
}
