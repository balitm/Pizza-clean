//
//  CartModel.swift
//  Domain
//
//  Created by Balázs Kilvády on 03/25/21.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Domain
import DataSource
import Factory

actor CartModel: Domain.CartModel {
    @Injected(\DataSourceContainer.storage) private var storage
    @Injected(\DataSourceContainer.pizzaAPI) private var network
    @Injected(\.componentsModel) private var component
    public private(set) var cart = Cart.empty

    /// Reload or init to empty.
    func initialize() async throws -> Cart {
        DLog("###### init cart. #########")
        let dsCart = DataSource.dbQueue.sync {
            storage.values(DataSource.Cart.self).first ?? DataSource.Cart(pizzas: [], drinks: [])
        }
        var cart = await dsCart.asDomain(with: component.ingredients, drinks: component.drinks)
        cart.basePrice = await component.pizzas.basePrice
        return start(with: cart)
    }

    func start(with: Cart) -> Cart {
        cart = with
        return cart
    }

    func add(pizza: Pizza) -> Cart {
        cart.add(pizza: pizza)
        return cart
    }

    func add(pizzaIndex: Int) async -> Cart {
        await cart.add(pizza: component.pizzas.pizzas[pizzaIndex])
        return cart
    }

    func add(drink: Drink) -> Cart {
        cart.add(drink: drink)
        return cart
    }

    func add(drinkIndex: Int) async -> Cart {
        await cart.add(drink: component.drinks[drinkIndex])
        return cart
    }

    @discardableResult
    func remove(at index: Int) -> Cart {
        cart.remove(at: index)
        return cart
    }

    func items() -> [CartItem] {
        cart.items()
    }

    func totalPrice() -> Double {
        cart.totalPrice()
    }

    func empty() throws -> Cart {
        var cart = cart
        cart.empty()
        try _dbAction(storage)
        self.cart = cart
        return cart
    }

    func save() throws {
        try _dbAction(storage) {
            $0.add(cart.asDataSource())
        }
    }

    func checkout() async throws -> Cart {
        let dsCart = cart.asDataSource()
        try await network.checkout(cart: dsCart)
        return try empty()
    }
}

private func _dbAction(_ container: DataSource.Storage,
                       _ operation: (DataSource.WriteTransaction) -> Void = { _ in }) throws {
    try DataSource.dbQueue.sync {
        try container.write {
            $0.delete(DataSource.Pizza.self)
            $0.delete(DataSource.Cart.self)
            operation($0)
        }
    }
}
