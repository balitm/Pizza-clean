//
//  Injection.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 11..
//

import Foundation
import Factory

public final class DataSourceContainer: SharedContainer {
    public static let shared = DataSourceContainer()

    public let manager = ContainerManager()

    public var appConfig: Factory<AppConfigProtocol> {
        self { AppConfig() }
            .onTest { TestingAppConfig() }
            .singleton
    }

    public var pizzaAPI: Factory<PizzaNetwork> {
        self { APIPizzaNetwork() }.singleton
    }

    public var storage: Factory<DataSource.Storage> {
        self { DataSource.Storage() }.singleton
    }
}

extension DataSourceContainer: AutoRegistering {
    public func autoRegister() {
#if DEBUG
        Self.shared.pizzaAPI.onPreview { MockPizzaNetwork() }
        Self.shared.pizzaAPI.onTest { MockPizzaNetwork() }
#endif
    }
}
