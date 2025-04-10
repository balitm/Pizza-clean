//
//  ComponentsModelTests.swift
//  Models
//
//  Created by Balázs Kilvády on 2025. 04. 10..
//

import Testing
import RealmSwift
import Domain
@testable import Models

class ComponentsModelTests: NetworklessTestsBase {
    var testCart: Cart!

    override init() async throws {
        try await super.init()

        let componentDrinks = await component.drinks
        let componentPizzas = await component.pizzas
        guard componentDrinks.count >= 2 && componentPizzas.pizzas.count >= 2 else { return }
        let pizzas = [
            componentPizzas.pizzas[0],
            componentPizzas.pizzas[1],
        ]
        let drinks = [
            componentDrinks[0],
            componentDrinks[1],
        ]
        testCart = Cart(pizzas: pizzas, drinks: drinks, basePrice: 4.0)
    }

    @Test func pizzaConversion() async {
        let pizzas = await component.pizzas
        let ingredients = await component.ingredients
        let dsPizzas = pizzas.asDataSource()
        let isConverted =
            dsPizzas.pizzas.count == pizzas.pizzas.count
                && dsPizzas.pizzas.reduce(true) { r0, pizza in
                    r0 && pizza.ingredients.reduce(true) { r1, id in
                        r1 && ingredients.contains { $0.id == id }
                    }
                }

        #expect(isConverted)
    }

    @Test func cartConversion() async {
        let cart = testCart!

        let converted = await cart.asDataSource().asDomain(with: component.ingredients, drinks: component.drinks)
        DLog("converted:\n", converted.drinks.map(\.id), "\norig:\n", cart.drinks.map(\.id))
        let isConverted = _isEqual(converted, rhs: cart)
        #expect(isConverted)
    }

    private func _isEqual(_ lhs: Domain.Cart, rhs: Domain.Cart) -> Bool {
        lhs.pizzas.map(\.name) == rhs.pizzas.map(\.name)
            && lhs.drinks.map(\.id) == rhs.drinks.map(\.id)
    }
}
