//
//  PizzasResult.swift
//  Domain
//
//  Created by Balázs Kilvády on 05/14/21.
//

import Foundation

// TODO: drop file
public struct PizzasResult: Sendable {
    public let pizzas: Pizzas
    public let error: APIError?

    static let empty = PizzasResult(pizzas: Pizzas.empty, error: nil)

    public init(pizzas: Pizzas, error: APIError? = nil) {
        self.pizzas = pizzas
        self.error = error
    }
}
