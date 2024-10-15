//
//  MenuUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/14/20.
//

import Foundation
import Combine

public protocol MenuUseCase {
    /// Initialize components.
    func initialize() async throws

    /// DataSource of available pizzas.
    func pizzas() async -> Pizzas

    /// Add a pizza to the shopping cart.
    func addToCart(pizza: Pizza) async throws
}
