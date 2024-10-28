//
//  IngredientsRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/16/20.
//

import Foundation
import Domain
import Factory

struct IngredientsRepository: IngredientsUseCase {
    @Injected(\.initActor) fileprivate var initActor
    private var _pizza: Pizza!
    private var ingredients = [IngredientSelection]()

    mutating func selectedIngredients(for pizza: Pizza) async -> [IngredientSelection] {
        _pizza = pizza
        return await selectedIngredients()
    }

    mutating func selectedIngredients() async -> [IngredientSelection] {
        let ingredients = await initActor.component.ingredients
        self.ingredients = createSelecteds(_pizza, ingredients)
        return self.ingredients
    }

    mutating func select(ingredientIndex index: Int) -> [IngredientSelection] {
        var ings = ingredients
        let item = ingredients[index]
        ings[index] = IngredientSelection(ingredient: item.ingredient, isOn: !item.isOn)
        ingredients = ings
        return ings
    }

    func addToCart() async {
        let newPizza = Pizza(copy: _pizza, name: name(), with: ingredients.compactMap { $0.isOn ? $0.ingredient : nil })
        _ = await initActor.cartHandler.add(pizza: newPizza)
    }

    func name() -> String {
        customName(String(repository: .emptyPizzaName))
    }

    func title() -> String {
        customName(String(repository: .emptyPizzaTitle))
    }

    private func customName(_ emptyName: String) -> String {
        guard !_pizza.ingredients.isEmpty else { return emptyName }

        let selectedNames = Set(ingredients
            .compactMap { selection in
                selection.isOn ? selection.ingredient.name : nil
            })
        let pizzaNames = Set(_pizza.ingredients
            .map(\.name))
        let pre = if selectedNames != pizzaNames {
            String(repository: .customPrefix)
        } else {
            ""
        }
        return "\(pre)\(_pizza.name)"
    }

    func sum() -> Double {
        let selecteds = ingredients
            .compactMap { selection in
                selection.isOn ? selection.ingredient : nil
            }
        return selecteds.reduce(0.0) { $0 + $1.price }
    }

    func pizza() -> Pizza {
        _pizza
    }
}

/// Create array of Ingredients with selectcion flag.
private func createSelecteds(_ pizza: Pizza, _ ingredients: [Ingredient]) -> [IngredientSelection] {
    func isContained(_ ingredient: Ingredient) -> Bool {
        pizza.ingredients.contains { $0.id == ingredient.id }
    }

    let sels = ingredients.map { ing -> IngredientSelection in
        IngredientSelection(ingredient: ing, isOn: isContained(ing))
    }
    return sels
}

#if DEBUG
struct PreviewIngredientsRepository: IngredientsUseCase {
    var implementation = IngredientsRepository()

    mutating func selectedIngredients(for pizza: Pizza) async -> [IngredientSelection] {
        _ = try? await implementation.initActor.initialize()
        return await implementation.selectedIngredients(for: pizza)
    }

    mutating func selectedIngredients() async -> [IngredientSelection] {
        await implementation.selectedIngredients()
    }

    mutating func select(ingredientIndex index: Int) -> [IngredientSelection] {
        implementation.select(ingredientIndex: index)
    }

    func addToCart() async {
        await implementation.addToCart()
    }

    func name() -> String {
        implementation.name()
    }

    func title() -> String {
        implementation.title()
    }

    func pizza() -> Pizza {
        implementation.pizza()
    }

    func sum() -> Double {
        implementation.sum()
    }
}
#endif
