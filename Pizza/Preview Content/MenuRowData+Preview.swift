//
//  MenuRowData+Preview.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2024. 10. 23..
//

import Foundation
import Domain

extension MenuRowData {
    static func preview(from pizzzas: Pizzas, at index: Int) -> Self {
        Self(index: index, basePrice: pizzzas.basePrice, pizza: pizzzas.pizzas[index]) { _ in }
    }
}
