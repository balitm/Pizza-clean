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

final class MenuModelTests: NetworklessTestsBase {
    @Injected(\.menuModel) var menuModel

    @Test func initialize() async throws {
        try? await menuModel.initialize()
        await #expect(menuModel.pizzas().basePrice > 0)
    }

    @Test func pizzas() async throws {
        let pizzas = await menuModel.pizzas()
        DLog("all pizzas: ", pizzas.pizzas.count)
        #expect(!pizzas.pizzas.isEmpty)
    }

    @Test func addPizza() async throws {
        try await addItemTest(addItem: { [component, menuModel] in
            let pizza = await component!.pizzas.pizzas.first!
            await menuModel.addToCart(pizza: pizza)
        })
    }
}
