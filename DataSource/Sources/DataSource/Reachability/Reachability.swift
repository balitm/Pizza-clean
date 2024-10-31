//
//  Reachability.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 30..
//

import Foundation
import Reachability
import Domain
import Factory

public protocol ReachabilityUseCase {
    var connection: AsyncStream<Reachability.Connection> { get }
}

final class Reachable: ReachabilityUseCase {
    var connection: AsyncStream<Reachability.Connection> {
        AsyncStream { continuation in
            do {
                let reachability = try createReachability()

                reachability.whenReachable = { reach in
                    continuation.yield(reach.connection)
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
