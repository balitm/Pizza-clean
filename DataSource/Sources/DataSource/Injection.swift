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

#if DEBUG
    var mockPizzaAPI: Factory<PizzaNetwork> {
        self { MockPizzaNetwork() }.singleton
    }
#endif
}
