//
//  CartRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/16/20.
//

import Foundation
import Domain
import Factory

struct CartRepository: CartUseCase {
    @Injected(\.initActor) private var initActor
    @Injected(\.pizzaAPI) private var network

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
