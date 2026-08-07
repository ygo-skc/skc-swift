//
//  GRPC.swift
//  SKCSwift
//
//  Created by Javi Gomez on 10/13/25.
//

import GRPCCore
import GRPCNIOTransportHTTP2TransportServices
import SwiftProtobuf
import os

fileprivate actor YGOClientProvider {
    static let shared = YGOClientProvider(host: "ygo-service.skc.cards")

    private let host: String
    private var generation = 0
    private var clientTask: Task<YGOClients, any Error>?

    init(host: String) {
        self.host = host
    }

    func getClients() async throws -> YGOClients {
        if let clientTask {
            return try await clientTask.value
        }

        generation += 1
        let currentGeneration = generation
        let task = Task {
            do {
                let clients = try await MainActor.run { try YGOClients(host: host) }

                Task {
                    do {
                        try await clients.runConnections()
                        Logger.network.debug("gRPC connection loop finished")
                    } catch {
                        Logger.network.error("gRPC runConnections terminated: \(error, privacy: .public)")
                    }
                    invalidate(generation: currentGeneration)
                }

                return clients
            } catch {
                invalidate(generation: currentGeneration)
                throw error
            }
        }
        clientTask = task

        return try await task.value
    }

    private func invalidate(generation: Int) {
        guard generation == self.generation else { return }
        clientTask = nil
    }
}

fileprivate struct YGOClients: Sendable {
    let productService: Ygo_ProductService.Client<HTTP2ClientTransport.TransportServices>
    let restrictionService: Ygo_CardRestrictionService.Client<HTTP2ClientTransport.TransportServices>
    let scoreService: Ygo_ScoreService.Client<HTTP2ClientTransport.TransportServices>

    private let client: GRPCClient<HTTP2ClientTransport.TransportServices>

    init(host: String) throws {
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
        productService = Ygo_ProductService.Client(wrapping: client)
        restrictionService = Ygo_CardRestrictionService.Client(wrapping: client)
        scoreService = Ygo_ScoreService.Client(wrapping: client)
        self.client = client
    }

    nonisolated func runConnections() async throws {
        try await client.runConnections()
    }
}

private func rpcResult<T: Codable>(_ rpcCall: () async throws -> T) async -> Result<T, any Error> {
    do { return .success(try await rpcCall()) }
    catch { return .failure(error) }
}

@concurrent
nonisolated func getProductsReleasedSameDay(date: String) async -> Result<[Product], any Error> {
    return await rpcResult {
        let res = try await YGOClientProvider.shared.getClients().productService.getProductsReleasedSameDay(
            .with {
                $0.date = date
            })
        return res.products.map { .init(from: $0) }
    }
}

@concurrent
nonisolated public func getRestrictionDates(format: String) async -> Result<[String], any Error> {
    return await rpcResult {
        let timeline = try await YGOClientProvider.shared.getClients().restrictionService.getEffectiveTimelineForFormat(.with { $0.value = format })
        return timeline.allDates
    }
}

@concurrent
nonisolated func getScoresByFormatAndDate(format: String, date: String, sort: Ygo_CardRestrictionSortOrder) async -> Result<CardScores, any Error> {
    return await rpcResult {
        let scores = try await YGOClientProvider.shared.getClients().scoreService.getScoresByFormatAndDate(
            .with {
                $0.format = format
                $0.effectiveDate = date
                $0.sortOrder = sort
            })
        let values = scores.entries.map{ CardScoreEntry(from: $0) }
        return CardScores(format: format, effectiveDate: date, entries: values, totalEntries: UInt32(values.count))
    }
}

@concurrent
nonisolated func getCardScore(cardID: String) async -> Result<CardScore, any Error> {
    return await rpcResult {
        let cardScore = try await YGOClientProvider.shared.getClients().scoreService.getCardScoreByID(.with { $0.id = cardID })
        return CardScore(currentScoreByFormat: cardScore.currentScoreByFormat,
                         uniqueFormats: cardScore.uniqueFormats,
                         scheduledChanges: cardScore.scheduledChanges)
    }
}
