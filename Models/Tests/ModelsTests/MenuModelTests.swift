//
//  MenuModelTests.swift
//  Models
//
//  Created by Balázs Kilvády on 2025. 04. 13..
//

import Testing
import Factory
import Domain
@testable import Models

class MenuModelTests: NetworklessTestsBase {
    @Injected(\.menuModel) var menuModel

    @Test func pizzas() async throws {
        let pizzas = await menuModel.pizzas()
        DLog("all pizzas: ", pizzas.pizzas.count)
        #expect(!pizzas.pizzas.isEmpty)
    }

    @Test func addPizza() async throws {
        try await addItemTest(addItem: {
            let pizza = await self.component.pizzas.pizzas.first!
            await self.menuModel.addToCart(pizza: pizza)
        })
    }
}
