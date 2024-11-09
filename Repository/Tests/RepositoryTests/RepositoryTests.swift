//
//  RepositoryTests.swift
//  DomainTests
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Testing
import RealmSwift
import Domain
@testable import Repository

class RepositoryTests: NetworklessUseCaseTestsBase {
    var testCart: Cart!

    override init() async throws {
        try await super.init()

        guard component.drinks.count >= 2 && component.pizzas.pizzas.count >= 2 else { return }
        let pizzas = [
            component.pizzas.pizzas[0],
            component.pizzas.pizzas[1],
        ]
        let drinks = [
            component.drinks[0],
            component.drinks[1],
        ]
        testCart = Cart(pizzas: pizzas, drinks: drinks, basePrice: 4.0)
    }

    @Test func pizzaConversion() async {
        let pizzas = component.pizzas
        let dsPizzas = pizzas.asDataSource()
        let isConverted =
            dsPizzas.pizzas.count == pizzas.pizzas.count
                && dsPizzas.pizzas.reduce(true) { r0, pizza in
                    r0 && pizza.ingredients.reduce(true) { r1, id in
                        r1 && component.ingredients.contains { $0.id == id }
                    }
                }

        #expect(isConverted)
    }

    @Test func cartConversion() async {
        let cart = testCart!

        let converted = cart.asDataSource().asDomain(with: component.ingredients, drinks: component.drinks)
        DLog("converted:\n", converted.drinks.map(\.id), "\norig:\n", cart.drinks.map(\.id))
        let isConverted = _isEqual(converted, rhs: cart)
        #expect(isConverted)
    }

    private func _isEqual(_ lhs: Domain.Cart, rhs: Domain.Cart) -> Bool {
        lhs.pizzas.map(\.name) == rhs.pizzas.map(\.name)
            && lhs.drinks.map(\.id) == rhs.drinks.map(\.id)
    }
}
