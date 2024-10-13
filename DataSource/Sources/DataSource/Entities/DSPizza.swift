//
//  DSPizza.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain

public extension DataSource {
    struct Pizza: Codable, Sendable {
        public let name: String
        public let ingredients: [Ingredient.ID]
        public let imageUrl: String?

        public init(name: String, ingredients: [Ingredient.ID], imageUrl: String? = nil) {
            self.name = name
            self.ingredients = ingredients
            self.imageUrl = imageUrl
        }
    }
}
