//
//  DatabaseTest.swift
//  DataSource
//
//  Created by Balázs Kilvády on 2024. 10. 11..
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Testing
import RealmSwift
import Factory
@testable import DataSource

struct DatabaseTest {
    let container: DS.Storage
    let mock: PizzaNetwork

    init() async throws {
        container = DataSourceContainer.shared.storage()
        mock = DataSourceContainer.shared.pizzaAPI()
        debugPrint(#fileID, #line, "!!! test case init -", container.path)
    }

    @Test func save() async throws {
        let drinks = try! await mock.getDrinks()
        debugPrint(#fileID, #line, drinks)
        #expect(!drinks.isEmpty)

        let pizzas = try! await mock.getPizzas()
        debugPrint(#fileID, #line, pizzas)
        #expect(!pizzas.pizzas.isEmpty)

        let cart = DS.Cart(
            pizzas: Array(pizzas.pizzas.prefix(2)),
            drinks: Array(drinks.prefix(2).map(\.id))
        )

        let error = dbAction(container) {
            $0.add(cart)
        }
        #expect(error == nil)

        DS.dbQueue.sync {
            do {
                let carts = container.values(DS.Cart.self)
                #expect(carts.count == 1)
                let cart = carts.first!
                #expect(cart.pizzas.count == 2)
                #expect(cart.drinks.count == 2)
                for drink in cart.drinks.enumerated() {
                    #expect(drink.element == drinks[drink.offset].id)
                }
                for pizza in cart.pizzas.enumerated() {
                    #expect(pizza.element.name == pizzas.pizzas[pizza.offset].name)
                    #expect(pizza.element.ingredients.count == pizzas.pizzas[pizza.offset].ingredients.count)
                    for ingredient in pizza.element.ingredients.enumerated() {
                        #expect(ingredient.element == pizzas.pizzas[pizza.offset].ingredients[ingredient.offset])
                    }
                }
                try container.write {
                    $0.delete(DS.Pizza.self)
                    $0.delete(DS.Cart.self)
                }
            } catch {
                Issue.record("Database threw \(error)")
            }
        }
    }
}

private func dbAction(
    _ container: DS.Storage?,
    _ operation: (DS.WriteTransaction) -> Void = { _ in }
) -> Error? {
    do {
        try DS.dbQueue.sync {
            try container?.write {
                $0.delete(DS.Pizza.self)
                $0.delete(DS.Cart.self)
                operation($0)
            }
        }
        return nil
    } catch {
        return error
    }
}
