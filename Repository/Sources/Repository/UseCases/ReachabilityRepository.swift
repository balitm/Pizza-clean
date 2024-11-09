//
//  ReachabilityRepository.swift
//  Repository
//
//  Created by Balázs Kilvády on 2024. 11. 01..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Domain
import DataSource
import Reachability
import Factory

struct ReachabilityRepository: ReachabilityUseCase {
    @Injected(\DataSourceContainer.pizzaAPI) private var api

    var connection: AsyncStream<Connection> {
        AsyncStream { continuation in
            do {
                let reachability = try createReachability()

                reachability.whenReachable = { reach in
                    let connection: Connection = switch reach.connection {
                    case .wifi: .wifi
                    case .cellular: .cellular
                    case .unavailable: .unavailable
                    }
                    continuation.yield(connection)
                }
                reachability.whenUnreachable = { _ in
                    continuation.yield(.unavailable)
                }

                continuation.onTermination = { _ in
                    reachability.stopNotifier()
                }

                do {
                    try reachability.startNotifier()
                } catch {
                    DLog(l: .error, "Unable to start reachability notifier: \(error.localizedDescription)")
                    continuation.finish()
                }
            } catch {
                DLog(l: .error, "reachability init failed with \(error.localizedDescription)")
                continuation.finish()
            }
        }
    }

    func resetSession() async {
        await api.resetSession()
    }
}

private func createReachability() throws -> Reachability {
    let config = DataSourceContainer.shared.appConfig()
    guard let url = URL(string: config.pizzaBaseURL), let host = url.host() else {
        throw ReachabilityError.failedToCreateWithHostname("", -1)
    }
    do {
        return try Reachability(hostname: host)
    } catch {
        return try Reachability()
    }
}

extension Reachability.Connection: @retroactive @unchecked Sendable {}
extension Reachability: @retroactive @unchecked Sendable {}
