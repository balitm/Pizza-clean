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

    var appConfig: Factory<AppConfigProtocol> {
        self { AppConfig() }.singleton
    }
}

extension Container: @retroactive AutoRegistering {
    public func autoRegister() {
#if DEBUG
        Container.shared.pizzaAPI.onPreview { MockPizzaNetwork() }
        Container.shared.pizzaAPI.onTest { MockPizzaNetwork() }
        Container.shared.appConfig.onTest { TestingAppConfig() }
#endif
    }
}
