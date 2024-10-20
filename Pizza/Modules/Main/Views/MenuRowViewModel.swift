//
//  MenuRowViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain

final class MenuRowViewModel {
    let index: Int
    let nameText: String
    let ingredientsText: String
    let priceText: String
    let url: URL?
    let onTapPrice: (Int) -> Void

    init(index: Int, basePrice: Double, pizza: Pizza, onTapPrice: @escaping (Int) -> Void) {
        self.index = index
        nameText = pizza.name
        let price = pizza.price(from: basePrice)
        priceText = format(price: price)
        ingredientsText = pizza.ingredientNames()
        url = pizza.imageUrl
        self.onTapPrice = onTapPrice
    }

    func addToCart() {
        onTapPrice(index)
    }
}

extension MenuRowViewModel: Identifiable {
    var id: Int { index }
}
