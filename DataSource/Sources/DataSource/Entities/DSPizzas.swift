//
//  DSPizzas.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain

public extension DataSource {
    struct Pizzas: Codable, Sendable {
        public let pizzas: [Pizza]
        public let basePrice: Double

        public init() {
            pizzas = []
            basePrice = 0
        }

        public init(pizzas: [Pizza], basePrice: Double) {
            self.pizzas = pizzas
            self.basePrice = basePrice
        }
    }
}
