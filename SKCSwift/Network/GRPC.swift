//
//  GRPC.swift
//  SKCSwift
//
//  Created by Javi Gomez on 10/13/25.
//

import GRPCCore
import GRPCNIOTransportHTTP2TransportServices
import SwiftProtobuf

fileprivate enum GRPCManager {
    static let ygoClients = YGOClients(host: "ygo-service.skc.cards")
}

fileprivate struct YGOClients {
    let restrictions: Ygo_CardRestrictionService.Client<HTTP2ClientTransport.TransportServices>
    let score: Ygo_ScoreService.Client<HTTP2ClientTransport.TransportServices>
    private let client: GRPCClient<HTTP2ClientTransport.TransportServices>
    
    init(host: String) {
        do {
            let transport = try HTTP2ClientTransport.TransportServices(
                target: .dns(host: host, port: 443),
                transportSecurity: .tls,
                config: .defaults { config in
                    config.compression = .init(
                        algorithm: .gzip,
                        enabledAlgorithms: [.gzip]
                    )
                    
                    config.backoff = .init(
                        initial: .milliseconds(80),
                        max: .seconds(1),
                        multiplier: 1.4,
                        jitter: 0.25
                    )
                    
                    config.connection = .init(
                        maxIdleTime: .seconds(60),
                        keepalive: .init(
                            time: .seconds(20),
                            timeout: .seconds(3),
                            allowWithoutCalls: false
                        )
                    )
                    config.connection.flushCoalescing = .init(maxFlushDelay: .microseconds(50), maxBytes: 100 << 10)
                    
                    config.http2 = .init(maxFrameSize: 20 << 10, targetWindowSize: 200 << 10, authority: nil)
                },
                serviceConfig: .init(
                    methodConfig: [
                        .init(
                            names: [.init(service: "", method: "")],
                            waitForReady: false,
                            timeout: .seconds(8),
                            executionPolicy: .retry(
                                .init(
                                    maxAttempts: 3,
                                    initialBackoff: .milliseconds(150),
                                    maxBackoff: .milliseconds(500),
                                    backoffMultiplier: 1.5,
                                    retryableStatusCodes: [.unknown, .deadlineExceeded, .dataLoss, .unavailable]))
                        )
                    ]
                )
            )
            let client = GRPCClient(transport: transport)
            
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
nonisolated func getScoresByFormatAndDate(format: String, date: String, sort: Int) async -> Result<CardScores, any Error> {
    do {
        let scores = try await GRPCManager.ygoClients.score.getScoresByFormatAndDate(
            .with {
                $0.format = format
                $0.effectiveDate = date
                switch(sort) {
                case 0:
                    $0.sortOrder = .cardColorAscCardNameAsc
                case 1:
                    $0.sortOrder = .scoreDescCardColorAscCardNameAsc
                default:
                    $0.sortOrder = .cardColorAscCardNameAsc
                }
            })
        let values = scores.entries.map({
            let card = $0.card
            return CardScoreEntry.fromRPC(
                cardID: card.id,
                cardName: card.name,
                cardColor: card.color,
                cardAttribute: card.attribute,
                cardEffect: card.effect,
                monsterType: (card.hasMonsterType) ?  card.monsterType.value : nil,
                monsterAttack: (card.hasAttack) ? Int(card.attack.value) : nil,
                monsterDefense: (card.hasDefense) ? Int(card.defense.value) : nil,
                score: $0.score
            )
        })
        return .success(CardScores.fromRPC(format: format, effectiveDate: date, entries: values, totalEntries: scores.totalEntries))
    } catch {
        return .failure(error)
    }
}

@concurrent
nonisolated func getCardScore(cardID: String) async -> Result<CardScore, any Error> {
    do {
        let cardScore = try await GRPCManager.ygoClients.score.getCardScoreByID(.with { $0.id = cardID })
        return .success(
            CardScore.fromRPC(
                currentScoreByFormat: cardScore.currentScoreByFormat,
                uniqueFormats: cardScore.uniqueFormats,
                scheduledChanges: cardScore.scheduledChanges)
        )
    } catch {
        return .failure(error)
    }
}
