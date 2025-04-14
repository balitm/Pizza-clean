//
//  IngredientsModelTests.swift
//  Models
//
//  Created by Balázs Kilvády on 2025. 04. 11..
//

import Testing
import Domain
import Factory
@testable import Models

// @Suite(.serialized) class IngredientsModelTests: NetworklessTestsBase {
@MainActor class IngredientsModelTests: NetworklessTestsBase, Sendable {
    @Injected(\.ingredientsModel) var model

    @Test func testIngredients() async throws {
        let pizza = await component.pizzas.pizzas[0]
        var selection = await model.selectedIngredients(for: pizza)
        selection = model.select(at: 0)
        #expect(!selection.isEmpty)
        selection = model.select(at: 1)
        let selecteds = selection.enumerated().compactMap { index, elem in
            elem.isOn ? "\(index): \(elem.ingredient.name)" : nil
        }
        DLog(l: .trace, "selected items: \(selecteds)")
        #expect(!selection.isEmpty)
    }

    @Test func addPizza() async throws {
        let pizza = await component.pizzas.pizzas[0]
        _ = await model.selectedIngredients(for: pizza)
        try await addItemTest(addItem: { @MainActor [model] in
            await model.addToCart()
        })
    }
}
