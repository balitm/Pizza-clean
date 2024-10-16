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
    @Injected(\.initActor) private var initActor
    private var _pizza: Pizza!
    private var ingredients = [IngredientSelection]()

    mutating func selectedIngredients(for pizza: Pizza) async -> [IngredientSelection] {
        _pizza = pizza
        return await selectedIngredients()
    }

    mutating func selectedIngredients() async -> [IngredientSelection] {
        let ingredients = await initActor.component.ingredients
        self.ingredients = _createSelecteds(_pizza, ingredients)
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
        let newPizza = Pizza(copy: _pizza, with: ingredients.compactMap { $0.isOn ? $0.ingredient : nil })
        _ = await initActor.cartHandler.add(pizza: newPizza)
    }

    func name() -> String {
        _pizza.ingredients.isEmpty ? "CREATE A PIZZA" : _pizza.name.uppercased()
    }

    func pizza() -> Pizza {
        _pizza
    }
}

/// Create array of Ingredients with selectcion flag.
private func _createSelecteds(_ pizza: Pizza, _ ingredients: [Ingredient]) -> [IngredientSelection] {
    func isContained(_ ingredient: Ingredient) -> Bool {
        pizza.ingredients.contains { $0.id == ingredient.id }
    }

    let sels = ingredients.map { ing -> IngredientSelection in
        IngredientSelection(ingredient: ing, isOn: isContained(ing))
    }
    return sels
}
