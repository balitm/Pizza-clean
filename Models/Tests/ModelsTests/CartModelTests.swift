//
//  CartModelTests.swift
//  Models
//
//  Created by Balázs Kilvády on 2025. 04. 10..
//

import Testing
import Factory
import RealmSwift
import Domain
import DataSource
@testable import Models

typealias DS = DataSource

@Suite(.serialized) class CartModelsTests: NetworklessTestsBase {
    @Injected(\DataSourceContainer.storage) var storage

    override init() async throws {
        try await super.init()

        guard await component.drinks.count >= 2, await component.pizzas.pizzas.count >= 2 else {
            Issue.record("no enough components.")
            return
        }

        let pizzas = await [
            component.pizzas.pizzas[0],
            component.pizzas.pizzas[1],
        ]
        let drinks = await [
            component.drinks[0],
            component.drinks[1],
        ]
        let cart = Cart(pizzas: pizzas, drinks: drinks, basePrice: 4.0)

        _ = await cartModel.start(with: cart)
    }

    @Test func items() async throws {
        let items = await cartModel.cart.items()

        let pizzas = await pizzaIndexes(items)
        let drins = await drinkIndexes(items)
        #expect(pizzas == [0, 1])
        #expect(drins == [2, 3])
    }

    @Test func remove() async throws {
        let componentPizzas = await component.pizzas
        let componentDrinks = await component.drinks

        // Remove the 1st pizza.
        await cartModel.remove(at: 0)
        var cart = await cartModel.cart
        #expect(cart.pizzas.count == 1)
        #expect(cart.drinks.count == 2)
        #expect(cart.pizzas[0].name == componentPizzas.pizzas[1].name)

        // Remove the 1st drink.
        await cartModel.remove(at: 1)
        cart = await cartModel.cart
        #expect(cart.pizzas.count == 1)
        #expect(cart.drinks.count == 1)
        #expect(cart.drinks[0].name == componentDrinks[1].name)
    }

    @Test func totoal() async throws {
        var total = 0.0

        total = await cartModel.totalPrice()

        let cart = await cartModel.cart
        let pp = cart.pizzas.reduce(0.0) {
            $0 + $1.ingredients.reduce(cart.basePrice) {
                $0 + $1.price
            }
        }
        let dp = cart.drinks.reduce(0.0) {
            $0 + $1.price
        }

        #expect(total == pp + dp)

        let items = await cartModel.items()
        let t = items.reduce(0.0) { $0 + $1.price }
        DLog(l: .trace, "items's sum: \(t)")
        #expect(t == total)
    }

    @Test func checkout() async throws {
        let rcart = try await cartModel.checkout()
        let cart = await cartModel.cart

        DLog(l: .trace, "after checkout: \(rcart.pizzas.count) - \(cart.pizzas.count)")
        #expect(cart.pizzas.isEmpty)
        #expect(cart.drinks.isEmpty)
        #expect(rcart.pizzas.isEmpty)
        #expect(rcart.drinks.isEmpty)

        // Check if the db is empty.
        DS.dbQueue.sync {
            #expect(storage.values(DS.Pizza.self).isEmpty)
            #expect(storage.values(DS.Cart.self).isEmpty)
        }

        let items = await cartModel.items()
        #expect(items.isEmpty)

        let total = await cartModel.totalPrice()
        #expect(total == 0.0)
    }

    private func pizzaIndexes(_ items: [CartItem]) async -> [Int] {
        let pizzas = await component.pizzas.pizzas
        return items.enumerated().compactMap { item -> Int? in
            pizzas.contains(where: { $0.name == item.element.name }) ? item.offset : nil
        }
    }

    private func drinkIndexes(_ items: [CartItem]) async -> [Int] {
        let drinks = await component.drinks
        return items.enumerated().compactMap { item -> Int? in
            drinks.contains(where: { $0.name == item.element.name }) ? item.offset : nil
        }
    }
}
