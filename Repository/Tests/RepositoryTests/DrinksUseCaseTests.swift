//
//  DrinksUseCaseTests.swift
//
//
//  Created by Balázs Kilvády on 5/20/20.
//

import Testing
import Domain
import Factory
@testable import Repository

class DrinksUseCaseTests: NetworklessUseCaseTestsBase {
    var service: DrinksUseCase!

    override init() async throws {
        try await super.init()

        service = Container.shared.drinksUseCase()
    }

    @Test func drinks() async throws {
        let drinks = try await service.drinks()
        #expect(!drinks.isEmpty)
    }

    @Test func addDrink() async throws {
        try await addItemTest {
            try await self.service.addToCart(drinkIndex: 0)
        } test: { [unowned data = data!] in
            #expect($0.drinks.count == 1)
            let handler = await data.cartHandler
            let cart = await handler.cart
            let id = cart.drinks[0].id

            #expect($0.drinks[0].id == id)
        }
    }
}
