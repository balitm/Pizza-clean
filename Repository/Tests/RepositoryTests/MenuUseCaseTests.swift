//
//  MenuUseCaseTests.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/15/20.
//

import Testing
import Factory
import Domain
@testable import Repository

class MenuUseCaseTests: NetworklessUseCaseTestsBase {
    var service: MenuUseCase!

    override init() async throws {
        try await super.init()

        service = Container.shared.menuUseCase()
    }

    @Test func pizzas() async throws {
        let pizzas = await service.pizzas()

        DLog("all pizzas: ", pizzas.pizzas.count)
        #expect(!pizzas.pizzas.isEmpty)
    }

    @Test func addPizza() async throws {
        try await addItemTest(addItem: {
            let pizza = await self.data.component.pizzas.pizzas.first!
            await self.service.addToCart(pizza: pizza)
        })
    }
}
