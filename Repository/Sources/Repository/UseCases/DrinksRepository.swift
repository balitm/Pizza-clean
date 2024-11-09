//
//  DrinksRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/20/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Factory

struct DrinksRepository: DrinksUseCase {
    @Injected(\.initActor) fileprivate var initActor

    func drinks() async -> [Drink] {
        await initActor.component.drinks
    }

    func addToCart(drinkIndex: Int) async {
        let drinks = await initActor.component.drinks
        _ = await initActor.cartHandler.add(drink: drinks[drinkIndex])
    }
}

#if DEBUG
struct PreviewDrinksRepository: DrinksUseCase {
    let implementation = DrinksRepository()

    func drinks() async -> [Drink] {
        _ = try? await implementation.initActor.initialize()
        return await implementation.drinks()
    }

    func addToCart(drinkIndex: Int) async {
        await implementation.addToCart(drinkIndex: drinkIndex)
    }
}
#endif
