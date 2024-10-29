//
//  MenuRowData.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Factory
import struct SwiftUI.Image

final class MenuRowData: ObservableObject {
    @Published var image: Image?

    let index: Int
    let nameText: String
    let ingredientsText: String
    let priceText: String
    let url: URL?
    let onTapPrice: (Int) -> Void

    let pizza: Pizza

    @Injected(\.menuUseCase) private var menuUseCase

    init(index: Int, basePrice: Double, pizza: Pizza, onTapPrice: @escaping (Int) -> Void) {
        self.index = index
        nameText = pizza.name
        let price = pizza.price(from: basePrice)
        priceText = format(price: price)
        ingredientsText = pizza.ingredientNames()
        url = pizza.imageUrl
        self.onTapPrice = onTapPrice
        self.pizza = pizza
    }

    func addToCart() {
        onTapPrice(index)
    }

    @MainActor
    func downloadImage() async {
        image = try? await menuUseCase.dowloadImage(for: pizza)
    }
}

extension MenuRowData: Identifiable {
    var id: Int { index }
}
