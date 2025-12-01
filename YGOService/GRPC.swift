//
//  Data.swift
//  SKCSwift
//
//  Created by Javi Gomez on 10/13/25.
//

import GRPCCore
import GRPCNIOTransportHTTP2
import SwiftProtobuf

fileprivate actor GRPCManager {
    static let services = GRPCManager()
    
    private(set) lazy var client: GRPCClient<HTTP2ClientTransport.Posix> = {
        do {
            let client = try GRPCClient(
                transport: .http2NIOPosix(
                    target: .dns(host: "ygo-service.skc.cards", port: 443),
                    transportSecurity: .tls,
                    config: .defaults { config in
                        config.compression = .init(
                            algorithm: .gzip,
                            enabledAlgorithms: [.gzip, .none]
                        )
                        
                        config.backoff = .init(
                            initial: .milliseconds(150),
                            max: .seconds(12),
                            multiplier: 1.3,
                            jitter: 0.2
                        )
                        
                        config.connection = .init(
                            maxIdleTime: .seconds(3 * 10 * 60),
                            keepalive: .init(
                                time: .seconds(45),
                                timeout: .seconds(12),
                                allowWithoutCalls: true
                            )
                        )
                        
                        config.http2 = .init(maxFrameSize: 2 * 1024, targetWindowSize: 24 * 1024, authority: nil)
                    },
                    serviceConfig: .init(
                        methodConfig: [
                            .init(
                                names: [.init(service: "", method: "")],  // Empty service means all methods
                                waitForReady: true,
                                timeout: .seconds(12)
                            )
                        ]
                    )
                )
            )
            Task {
                try await client.runConnections()
            }
            return client
        } catch {
            fatalError("Failed to create GRPC client: \(error)")
        }
    }()
    
    private(set) lazy var restrictions = Ygo_CardRestrictionService.Client(wrapping: client)
    private(set) lazy var score = Ygo_ScoreService.Client(wrapping: client)
}

@concurrent
nonisolated public func getRestrictionDates(format: String) async -> Result<[String], any Error> {
    do {
        let timeline = try await GRPCManager.services.restrictions.getEffectiveTimelineForFormat(.with { $0.value = format })
        return .success(.init(timeline.allDates))
    } catch {
        return .failure(error)
    }
}

@concurrent
nonisolated public func getScoresByFormatAndDate<U>(format: String,
                                                    date: String,
                                                    mapper: (String, String, String, String?, String, String?, Int?, Int?, UInt32) -> U)
async -> Result<[U], any Error> where U: Decodable {
    do {
        let scores = try await GRPCManager.services.score.getScoresByFormatAndDate(.with {
            $0.format = format
            $0.effectiveDate = date
        })
        let values = scores.entries.map({
            mapper($0.card.id,
                   $0.card.name,
                   $0.card.color,
                   $0.card.attribute,
                   $0.card.effect,
                   $0.card.monsterType.value,
                   Int($0.card.attack.value),
                   Int($0.card.defense.value),
                   $0.score
            )
        })
        return .success(values)
    } catch {
        return .failure(error)
    }
}

@concurrent
nonisolated public func getCardScore<U>(cardID: String,
                            mapper: ([String: UInt32], [String], [String]) -> U
) async -> Result<U, any Error> where U: Decodable {
    do {
        let cardScore = try await GRPCManager.services.score.getCardScoreByID(.with { $0.id = cardID })
        return .success(mapper(cardScore.currentScoreByFormat, cardScore.uniqueFormats, cardScore.scheduledChanges))
    } catch {
        return .failure(error)
    }
}
