//
//  DSCart.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Domain

public extension DataSource {
    struct Cart: Codable, Sendable {
        public let pizzas: [DataSource.Pizza]
        public let drinks: [Drink.ID]

        public init(pizzas: [DataSource.Pizza], drinks: [Drink.ID]) {
            self.pizzas = pizzas
            self.drinks = drinks
        }
    }
}
