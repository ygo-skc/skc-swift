//
//  Data.swift
//  SKCSwift
//
//  Created by Javi Gomez on 10/13/25.
//

import GRPCCore
import GRPCNIOTransportHTTP2
import SwiftProtobuf

class GRPCManager {
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
}

public func getRestrictionDates(format: String) async  {
    let clock = ContinuousClock()
    let time = await clock.measure {
        let scoreService = Ygo_ScoreService.Client(wrapping: GRPCManager.client)
        let scoreDates = try? await scoreService.getDatesForFormat(.with { $0.value = format })
        print(scoreDates!.dates)
    }
    print(time)
}
