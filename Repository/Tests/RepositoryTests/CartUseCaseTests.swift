//
//  CartUseCaseTests.swift
//
//
//  Created by Balázs Kilvády on 5/17/20.
//

import Testing
import Factory
import RealmSwift
import Domain
import DataSource
@testable import Repository

class CartUseCaseTests: NetworklessUseCaseTestsBase {
    var service: CartUseCase!

    override init() async throws {
        try await super.init()

        service = Container.shared.cartUseCase()

        guard component.drinks.count >= 2 && component.pizzas.pizzas.count >= 2 else {
            Issue.record("no enough components.")
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
        let cart = Cart(pizzas: pizzas, drinks: drinks, basePrice: 4.0)

        _ = await data.cartHandler.start(with: cart)
    }

    @Test func items() async throws {
        let items = await service.items()

        let pizzas = self._pizzaIndexes(items)
        let drins = self._drinkIndexes(items)
        #expect(pizzas == [0, 1])
        #expect(drins == [2, 3])
    }

    @Test func remove() async throws {
        // Remove the 1st pizza.
        await service.remove(at: 0)
        var cart = await data.cartHandler.cart
        #expect(cart.pizzas.count == 1)
        #expect(cart.drinks.count == 2)
        #expect(cart.pizzas[0].name == component.pizzas.pizzas[1].name)

        // Remove the 1st drink.
        await service.remove(at: 1)
        cart = await data.cartHandler.cart
        #expect(cart.pizzas.count == 1)
        #expect(cart.drinks.count == 1)
        #expect(cart.drinks[0].name == component.drinks[1].name)
    }

    @Test func totoal() async throws {
        var total = 0.0

        total = await service.total()

        var cart = await data.cartHandler.cart
        let pp = cart.pizzas.reduce(0.0) {
            $0 + $1.ingredients.reduce(cart.basePrice) {
                $0 + $1.price
            }
        }
        let dp = cart.drinks.reduce(0.0) {
            $0 + $1.price
        }

        #expect(total == pp + dp)

        let items = await service.items()
        let t = items.reduce(0.0) { $0 + $1.price }
    }

    @Test func checkout() async throws {
        let rcart = try await service.checkout()

        let cart = await data.cartHandler.cart
        #expect(cart.pizzas.isEmpty)
        #expect(cart.drinks.isEmpty)
        #expect(rcart.pizzas.isEmpty)
        #expect(rcart.drinks.isEmpty)

        // Check if the db is empty.
        DS.dbQueue.sync {
            // #expect(CartUseCaseTests.realm.objects(RMPizza.self).isEmpty)
            // #expect(CartUseCaseTests.realm.objects(RMCart.self).isEmpty)
            #expect(storage.values(DS.Pizza.self).isEmpty)
            #expect(storage.values(DS.Cart.self).isEmpty)
        }

        let items = await service.items()
        #expect(items.isEmpty)

        let total = await service.total()
        #expect(total == 0.0)
    }

    private func _pizzaIndexes(_ items: [CartItem]) -> [Int] {
        items.enumerated().compactMap { item -> Int? in
            self.component.pizzas.pizzas.contains(where: { $0.name == item.element.name }) ? item.offset : nil
        }
    }

    private func _drinkIndexes(_ items: [CartItem]) -> [Int] {
        items.enumerated().compactMap { item -> Int? in
            self.component.drinks.contains(where: { $0.name == item.element.name }) ? item.offset : nil
        }
    }
}
