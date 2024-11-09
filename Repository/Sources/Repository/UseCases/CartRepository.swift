//
//  CartRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/16/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Domain
import DataSource
import Factory

struct CartRepository: CartUseCase {
    @Injected(\.initActor) fileprivate var initActor
    @Injected(\DataSourceContainer.pizzaAPI) private var network

    func items() async -> [CartItem] {
        await initActor.cartHandler.cart.items()
    }

    func total() async -> Double {
        await initActor.cartHandler.cart.totalPrice()
    }

    func remove(at index: Int) async {
        _ = await initActor.cartHandler.remove(index: index)
    }

    func checkout() async throws -> Cart {
        let dsCart = await initActor.cartHandler.cart.asDataSource()
        try await network.checkout(cart: dsCart)
        return try await initActor.cartHandler.empty()
    }
}

#if DEBUG
struct PreviewCartRepository: CartUseCase {
    let implementation = CartRepository()

    func items() async -> [CartItem] {
        if let components = try? await implementation.initActor.initialize() {
            _ = await implementation.initActor.cartHandler.add(drink: components.drinks[0])
            _ = await implementation.initActor.cartHandler.add(drink: components.drinks[1])
            _ = await implementation.initActor.cartHandler.add(pizza: components.pizzas.pizzas[0])
            _ = await implementation.initActor.cartHandler.add(pizza: components.pizzas.pizzas[1])
        }
        return await implementation.items()
    }

    func total() async -> Double {
        await implementation.total()
    }

    func remove(at index: Int) async {
        await implementation.remove(at: index)
    }

    func checkout() async throws -> Cart {
        try await implementation.checkout()
    }
}
#endif
