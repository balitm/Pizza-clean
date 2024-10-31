//
//  Injection.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 11..
//

import Foundation
import Factory

public extension Container {
    var pizzaAPI: Factory<PizzaNetwork> {
        self { APIPizzaNetwork() }.singleton
    }

    var storage: Factory<DataSource.Storage> {
        self { DataSource.Storage() }.singleton
    }

    var reachability: Factory<ReachabilityUseCase> {
        self { Reachable() }.singleton
    }
}

extension Container: @retroactive AutoRegistering {
    public func autoRegister() {
#if DEBUG
        Container.shared.pizzaAPI.onPreview { MockPizzaNetwork() }
        Container.shared.pizzaAPI.onTest { MockPizzaNetwork() }
#endif
    }
}

public final class DataSourceContainer: SharedContainer {
    public static let shared = DataSourceContainer()

    public let manager = ContainerManager()

    public var appConfig: Factory<AppConfigProtocol> {
        self { AppConfig() }
            .onTest { TestingAppConfig() }
            .singleton
    }
}
