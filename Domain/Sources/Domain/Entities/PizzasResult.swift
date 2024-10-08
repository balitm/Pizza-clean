//
//  PizzasResult.swift
//  Domain
//
//  Created by Balázs Kilvády on 05/14/21.
//

import Foundation

public struct PizzasResult: Sendable {
    public let pizzas: Pizzas
    public let error: APIErrorType?

    static let empty = PizzasResult(pizzas: Pizzas.empty, error: nil)

    init(pizzas: Pizzas, error: APIErrorType? = nil) {
        self.pizzas = pizzas
        self.error = error
    }
}
