//
//  IngredientSelection.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/17/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation

public struct IngredientSelection: Sendable {
    public let ingredient: Ingredient
    public let isOn: Bool

    public init(ingredient: Ingredient, isOn: Bool) {
        self.ingredient = ingredient
        self.isOn = isOn
    }
}
