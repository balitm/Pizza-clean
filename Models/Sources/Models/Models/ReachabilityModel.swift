//
//  ReachabilityModel.swift
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

struct ReachabilityModel: Domain.ReachabilityModel {
    private var api: PizzaNetwork = DataSourceContainer.shared.pizzaAPI()
    // @Injected(\DataSourceContainer.pizzaAPI) private var api: PizzaNetwork
    private var cart = Container.shared.cartModel()
    // @Injected(\.cartModel) private var cart

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
        try? await cart.save()
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

extension Reachability: @retroactive @unchecked Sendable {}
