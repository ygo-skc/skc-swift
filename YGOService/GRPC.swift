//
//  Data.swift
//  SKCSwift
//
//  Created by Javi Gomez on 10/13/25.
//

import GRPCCore
import GRPCNIOTransportHTTP2
import SwiftProtobuf

fileprivate class GRPCManager {
    static let client: GRPCClient<HTTP2ClientTransport.Posix> = {
        do {
            let client = try GRPCClient(
                transport: .http2NIOPosix(
                    target: .dns(host: "ygo-service.skc.cards", port: 443),
                    transportSecurity: .tls,
                    config: .defaults { config in
                        config.compression = .init(algorithm: .gzip, enabledAlgorithms: [.gzip, .none])
                        config.backoff = .init(
                            initial: .milliseconds(80),
                            max: .seconds(1),
                            multiplier: 1.6,
                            jitter: 0.2
                        )
                        config.connection = .init(
                            maxIdleTime: .seconds(30 * 60),
                            keepalive: .init(
                                time: .seconds(60),
                                timeout: .seconds(3),
                                allowWithoutCalls: true
                            )
                        )
                    },
                    serviceConfig: .init(
                        methodConfig: [
                            .init(
                                names: [.init(service: "")],  // Empty service means all methods
                                waitForReady: true,
                                timeout: .seconds(3)
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
    
    static let restrictionService: Ygo_CardRestrictionService.Client = {
        return Ygo_CardRestrictionService.Client(wrapping: GRPCManager.client)
    }()
    
    static let scoreService: Ygo_ScoreService.Client = {
        return Ygo_ScoreService.Client(wrapping: GRPCManager.client)
    }()
}

@concurrent
public func getRestrictionDates(format: String) async -> Result<[String], any Error> {
    do {
        let timeline = try await GRPCManager.restrictionService.getEffectiveTimelineForFormat(.with { $0.value = format })
        return .success(.init(timeline.allDates))
    } catch {
        return .failure(error)
    }
}

@concurrent
public func getScoresByFormatAndDate<U>(format: String,
                                        date: String,
                                        mapper: (String, String, String, String?, String, String?, Int?, Int?, UInt32) -> U)
async -> Result<[U], any Error> where U: Decodable {
    do {
        let scores = try await GRPCManager.scoreService.getScoresByFormatAndDate(.with {
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
public func getCardScore<U>(cardID: String,
                            mapper: ([String: UInt32], [String], [String]) -> U
) async -> Result<U, any Error> where U: Decodable {
    do {
        let cardScore = try await GRPCManager.scoreService.getCardScoreByID(.with { $0.id = cardID })
        return .success(mapper(cardScore.currentScoreByFormat, cardScore.uniqueFormats, cardScore.scheduledChanges))
    } catch {
        return .failure(error)
    }
}
