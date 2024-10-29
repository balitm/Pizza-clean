//
//  IngredientsItemRowData+Preview.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 25..
//

import Foundation
import Domain

extension IngredientsItemRowData {
    static func preview(from pizzas: Pizzas, at index: Int, isContained: Bool) -> Self {
        Self(
            name: pizzas.pizzas[0].ingredients[index].name,
            priceText: format(price: pizzas.pizzas[0].ingredients[index].price),
            isContained: isContained,
            index: index
        )
    }
}
