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
}
