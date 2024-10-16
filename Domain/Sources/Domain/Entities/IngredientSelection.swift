//
//  IngredientSelection.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/17/20.
//

import Foundation

public struct IngredientSelection {
    public let ingredient: Ingredient
    public let isOn: Bool

    public init(ingredient: Ingredient, isOn: Bool) {
        self.ingredient = ingredient
        self.isOn = isOn
    }
}
