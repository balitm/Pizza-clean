//
//  IngredientsUseCaseTests.swift
//
//
//  Created by Balázs Kilvády on 5/16/20.
//

import Testing
import Domain
import Factory
@testable import Repository

@Suite(.serialized) class IngredientsUseCaseTests: NetworklessUseCaseTestsBase {
    var service: IngredientsUseCase!

    override init() async throws {
        try await super.init()

        service = Container.shared.ingredientsUseCase()
    }

    @Test func testIngredients() async throws {
        let pizza = component.pizzas.pizzas[0]
        var selection = await service.selectedIngredients(for: pizza)
        selection = service.select(ingredientIndex: 0)
        #expect(!selection.isEmpty)
        selection = service.select(ingredientIndex: 1)
        let selecteds = selection.enumerated().compactMap { index, elem in
            elem.isOn ? "\(index): \(elem.ingredient.name)" : nil
        }
        DLog(l: .trace, "selected items: \(selecteds)")
        #expect(!selection.isEmpty)
    }

    @Test func addPizza() async throws {
        let pizza = component.pizzas.pizzas[0]
        var selection = await service.selectedIngredients(for: pizza)
        try await addItemTest(addItem: { [service = service!] in
            await service.addToCart()
        })
    }
}
