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
    static let ygoClients = YGOClients(host: "ygo-service.skc.cards")
}

fileprivate struct YGOClients {
    let restrictions: Ygo_CardRestrictionService.Client<HTTP2ClientTransport.Posix>
    let score: Ygo_ScoreService.Client<HTTP2ClientTransport.Posix>
    private let client: GRPCClient<HTTP2ClientTransport.Posix>
    
    init(host: String) {
        do {
            let client = try GRPCClient(
                transport: .http2NIOPosix(
                    target: .dns(host: host, port: 443),
                    transportSecurity: .tls,
                    config: .defaults { config in
                        config.compression = .init(
                            algorithm: .gzip,
                            enabledAlgorithms: [.gzip]
                        )
                        
                        config.backoff = .init(
                            initial: .milliseconds(200),
                            max: .seconds(5),
                            multiplier: 1.3,
                            jitter: 0.2
                        )
                        
                        config.connection = .init(
                            maxIdleTime: .seconds(2 * 60),
                            keepalive: .init(
                                time: .seconds(30),
                                timeout: .seconds(5),
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
                                timeout: .seconds(6),
                                executionPolicy: .retry(
                                    .init(
                                        maxAttempts: 2,
                                        initialBackoff: .milliseconds(150),
                                        maxBackoff: .seconds(3),
                                        backoffMultiplier: 1.3,
                                        retryableStatusCodes: [.unknown, .deadlineExceeded, .dataLoss, .unavailable]))
                            )
                        ]
                    )
                )
            )
            Task {
                try await client.runConnections()
            }
            restrictions = Ygo_CardRestrictionService.Client(wrapping: client)
            score = Ygo_ScoreService.Client(wrapping: client)
            self.client = client
        } catch {
            fatalError("Failed to create GRPC client: \(error)")
        }
    }
}

@concurrent
nonisolated public func getRestrictionDates(format: String) async -> Result<[String], any Error> {
    do {
        let timeline = try await GRPCManager.ygoClients.restrictions.getEffectiveTimelineForFormat(.with { $0.value = format })
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
        let scores = try await GRPCManager.ygoClients.score.getScoresByFormatAndDate(.with {
            $0.format = format
            $0.effectiveDate = date
        })
        let values = scores.entries.map({
            let card = $0.card
            return mapper(
                card.id,
                card.name,
                card.color,
                card.attribute,
                card.effect,
                (card.hasMonsterType) ?  card.monsterType.value : nil,
                (card.hasAttack) ? Int(card.attack.value) : nil,
                (card.hasDefense) ? Int(card.defense.value) : nil,
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
        let cardScore = try await GRPCManager.ygoClients.score.getCardScoreByID(.with { $0.id = cardID })
        return .success(mapper(cardScore.currentScoreByFormat, cardScore.uniqueFormats, cardScore.scheduledChanges))
    } catch {
        return .failure(error)
    }
}
