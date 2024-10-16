//
//  Pizzas.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

public struct Pizzas: Sendable {
    public let pizzas: [Pizza]
    public let basePrice: Double

    public init(pizzas: [Pizza], basePrice: Double) {
        self.pizzas = pizzas
        self.basePrice = basePrice
    }

    public static let empty = Pizzas(pizzas: [], basePrice: 0)
}
