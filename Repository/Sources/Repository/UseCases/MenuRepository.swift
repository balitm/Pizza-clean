//
//  MenuRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/14/20.
//

import Foundation
import Domain
import Factory

actor MenuRepository: MenuUseCase {
    @Injected(\.initActor) private var initActor

    func initialize() async throws {
        _ = try await initActor.initialize()
    }

    func pizzas() async -> Pizzas {
        await initActor.component.pizzas
    }

    func addToCart(pizza: Pizza) async {
        _ = await initActor.cartHandler.add(pizza: pizza)
    }
}
