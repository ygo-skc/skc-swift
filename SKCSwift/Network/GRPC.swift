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
    let productService: Ygo_ProductService.Client<HTTP2ClientTransport.TransportServices>
    let restrictionService: Ygo_CardRestrictionService.Client<HTTP2ClientTransport.TransportServices>
    let scoreService: Ygo_ScoreService.Client<HTTP2ClientTransport.TransportServices>
    
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
                do {
                    try await client.runConnections()
                } catch {
                    print("gRPC runConnections terminated: \(error)")
                }
            }
            productService = Ygo_ProductService.Client(wrapping: client)
            restrictionService = Ygo_CardRestrictionService.Client(wrapping: client)
            scoreService = Ygo_ScoreService.Client(wrapping: client)
            self.client = client
        } catch {
            fatalError("Failed to create GRPC client: \(error)")
        }
    }
}

private func rpcResult<T: Codable>(_ rpcCall: () async throws -> T) async -> Result<T, any Error> {
    do { return .success(try await rpcCall()) }
    catch { return .failure(error) }
}

@concurrent
nonisolated public func getRestrictionDates(format: String) async -> Result<[String], any Error> {
    return await rpcResult {
        let timeline = try await GRPCManager.ygoClients.restrictionService.getEffectiveTimelineForFormat(.with { $0.value = format })
        return timeline.allDates
    }
}

@concurrent
nonisolated func getScoresByFormatAndDate(format: String, date: String, sort: Ygo_CardRestrictionSortOrder) async -> Result<CardScores, any Error> {
    return await rpcResult {
        let scores = try await GRPCManager.ygoClients.scoreService.getScoresByFormatAndDate(
            .with {
                $0.format = format
                $0.effectiveDate = date
                $0.sortOrder = sort
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
        return CardScores.fromRPC(format: format, effectiveDate: date, entries: values, totalEntries: scores.totalEntries)
    }
}

@concurrent
nonisolated func getCardScore(cardID: String) async -> Result<CardScore, any Error> {
    return await rpcResult {
        let cardScore = try await GRPCManager.ygoClients.scoreService.getCardScoreByID(.with { $0.id = cardID })
        return CardScore.fromRPC(
            currentScoreByFormat: cardScore.currentScoreByFormat,
            uniqueFormats: cardScore.uniqueFormats,
            scheduledChanges: cardScore.scheduledChanges
        )
    }
}
