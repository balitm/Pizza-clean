//
//  IngredientsModel.swift
//  Models
//
//  Created by Balázs Kilvády on 2025. 04. 11..
//

import Foundation
import Domain
import Factory

final class IngredientsModel: Domain.IngredientsModel {
    @Injected(\.componentsModel) fileprivate var component
    @Injected(\.cartModel) fileprivate var cartModel

    private var _pizza: Pizza!
    private var ingredients = [IngredientSelection]()

    func selectedIngredients(for pizza: Pizza) async -> [IngredientSelection] {
        _pizza = pizza
        return await selectedIngredients()
    }

    func selectedIngredients() async -> [IngredientSelection] {
        let ingredients = await component.ingredients
        self.ingredients = createSelecteds(_pizza, ingredients)
        return self.ingredients
    }

    func select(at index: Int) -> [IngredientSelection] {
        var ings = ingredients
        let item = ingredients[index]
        ings[index] = IngredientSelection(ingredient: item.ingredient, isOn: !item.isOn)
        ingredients = ings
        return ings
    }

    func addToCart() async {
        let newPizza = Pizza(copy: _pizza, name: name(), with: ingredients.compactMap { $0.isOn ? $0.ingredient : nil })
        await cartModel.add(pizza: newPizza)
    }

    func name() -> String {
        customName(String(models: .emptyPizzaName))
    }

    func title() -> String {
        customName(String(models: .emptyPizzaTitle))
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
            String(models: .customPrefix)
        } else {
            ""
        }
        return "\(pre)\(_pizza.name)"
    }

    func totalPrice() -> Double {
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
