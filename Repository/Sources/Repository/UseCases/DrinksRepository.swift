//
//  DrinksRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/20/20.
//

import Foundation
import Domain
import Factory

struct DrinksRepository: DrinksUseCase {
    @Injected(\.initActor) private var initActor

    func drinks() async throws -> [Drink] {
        await initActor.component.drinks
    }

    func addToCart(drinkIndex: Int) async throws {
        let drinks = await initActor.component.drinks
        _ = await initActor.cartHandler.add(drink: drinks[drinkIndex])
    }
}
