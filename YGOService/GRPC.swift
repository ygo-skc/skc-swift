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
    } catch let error as RPCError {
        handleRPCError(method: "Restriction Timeline", error: error)
        return .failure(error)
    } catch {
        print("Unexpected error:", error)
        return .failure(RPCError(code: .unknown, message: "Unexpected error"))
    }
}

@concurrent
public func getCardScore<U>(cardID: String, parser: ([String: UInt32], [String], [String]) -> U) async -> Result<U, any Error> where U: Decodable {
    do {
        let cardScore = try await GRPCManager.scoreService.getCardScoreByID(.with { $0.id = cardID })
        return .success(parser(cardScore.currentScoreByFormat, cardScore.uniqueFormats, cardScore.scheduledChanges))
    } catch let error as RPCError {
        handleRPCError(method: "Card Score", error: error)
        return .failure(error)
    } catch {
        print("Unexpected error:", error)
        return .failure(RPCError(code: .unknown, message: "Unexpected error"))
    }
}

fileprivate func handleRPCError(method: String, error: RPCError) {
    switch error.code {
    case .notFound:
        print("RPC \(method) call resulted in not found error. Message: \(error.message)")
    default:
        print("RPC error \(error.message)")
    }
}
