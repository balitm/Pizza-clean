//
//  MenuRowData.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright 2024 kil-dev. All rights reserved.
//

import ComposableArchitecture
import Domain
import Factory
import struct SwiftUI.Image

struct MenuRowData: Equatable {
    var image: Image?
    let index: Int
    let ingredientsText: String
    let priceText: String
    let pizza: Pizza

    init(index: Int, basePrice: Double, pizza: Pizza) {
        self.index = index
        let price = pizza.price(from: basePrice)
        priceText = format(price: price)
        ingredientsText = pizza.ingredientNames()
        self.pizza = pizza
    }

    init() {
        index = 0
        priceText = ""
        ingredientsText = ""
        pizza = .init()
    }
}

extension MenuRowData: Identifiable {
    var id: Int { index }
}
