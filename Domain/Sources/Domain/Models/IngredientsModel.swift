//
//  IngredientsModel.swift
//  Domain
//
//  Created by Balázs Kilvády on 2025. 04. 11..
//

import Foundation

@MainActor
public protocol IngredientsModel: Sendable {
    func selectedIngredients(for pizza: Pizza) async -> [IngredientSelection]
    func select(at index: Int) -> [IngredientSelection]
    func addToCart() async
    func name() -> String
    func title() -> String
    func totalPrice() -> Double
    func pizza() -> Pizza
}
