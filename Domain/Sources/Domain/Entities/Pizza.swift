//
//  Pizza.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation

public struct Pizza: Sendable {
    public let name: String
    public let ingredients: [Ingredient]
    public let imageUrl: URL?

    public init(copy other: Pizza, name: String? = nil, with ingredients: [Ingredient]? = nil) {
        self.name = name ?? other.name
        imageUrl = other.imageUrl
        self.ingredients = ingredients ?? other.ingredients
    }

    public init() {
        name = "Custom"
        imageUrl = nil
        ingredients = []
    }

    public init(
        name: String,
        ingredients: [Ingredient],
        imageUrl: URL?
    ) {
        self.name = name
        self.ingredients = ingredients
        self.imageUrl = imageUrl
    }

    public func price(from basePrice: Double) -> Double {
        let price = ingredients.reduce(basePrice) {
            $0 + $1.price
        }
        return price
    }

    public func ingredientNames() -> String {
        var iNames = ""
        var it = ingredients.makeIterator()
        if let first = it.next() {
            iNames = first.name
            while let ingredient = it.next() {
                iNames += ", " + ingredient.name
            }
            iNames += "."
        }
        return iNames
    }
}

extension Pizza: Hashable {
    public static func ==(lhs: Pizza, rhs: Pizza) -> Bool {
        lhs.name == rhs.name && lhs.imageUrl == rhs.imageUrl
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(imageUrl)
    }
}
