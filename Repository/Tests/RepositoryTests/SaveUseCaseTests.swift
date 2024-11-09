//
//  SaveUseCaseTests.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/21/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Testing
import Domain
import Factory
@testable import Repository

class SaveUseCaseTests: NetworklessUseCaseTestsBase {
    var service: SaveUseCase!

    override init() async throws {
        try await super.init()

        service = Container.shared.saveUseCase()
    }

    @Test func saveCart() async throws {
        guard component.drinks.count >= 2 && component.pizzas.pizzas.count >= 2 else {
            Issue.record("not enough components.")
            return
        }

        let pizzas = [
            component.pizzas.pizzas[0],
            component.pizzas.pizzas[1],
        ]
        let drinks = [
            component.drinks[0],
            component.drinks[1],
        ]

        let cart = Cart(pizzas: pizzas, drinks: drinks, basePrice: 4)
        _ = await data.cartHandler.start(with: cart)
        await #expect(data.cartHandler.cart.pizzas.count == 2)
        await #expect(data.cartHandler.cart.drinks.count == 2)

        do {
            try await service.saveCart()
        } catch {
            Issue.record("save cart failed: \(error)")
        }

        DS.dbQueue.sync {
            do {
                let carts = storage.values(DS.Cart.self)
                #expect(carts.count == 1)
                let cart = carts.first!
                #expect(cart.pizzas.count == 2)
                #expect(cart.drinks.count == 2)
                for drink in cart.drinks.enumerated() {
                    #expect(drink.element == component.drinks[drink.offset].id)
                }
                for pizza in cart.pizzas.enumerated() {
                    #expect(pizza.element.name == component.pizzas.pizzas[pizza.offset].name)
                }
                try storage.write {
                    $0.delete(DS.Pizza.self)
                    $0.delete(DS.Cart.self)
                }
            } catch {
                Issue.record("Database threw \(error)")
            }
        }
    }
}
