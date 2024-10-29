//
//  IngredientsUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/15/20.
//

import Foundation
import Combine

public protocol IngredientsUseCase {
    mutating func selectedIngredients(for pizza: Pizza) async -> [IngredientSelection]
    mutating func select(ingredientIndex index: Int) -> [IngredientSelection]
    func addToCart() async
    func name() -> String
    func pizza() -> Pizza
    func title() -> String
    func sum() -> Double
}
