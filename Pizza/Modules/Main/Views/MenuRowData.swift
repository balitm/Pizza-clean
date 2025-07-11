//
//  MenuRowData.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Factory
import struct SwiftUI.Image

@Observable final class MenuRowData {
    var image: Image?

    let index: Int
    let ingredientsText: String
    let priceText: String
    let onTapPrice: (Int) -> Void

    let pizza: Pizza

    @ObservationIgnored @Injected(\.menuModel) private var menuModel

    init(index: Int, basePrice: Double, pizza: Pizza, onTapPrice: @escaping (Int) -> Void) {
        self.index = index
        let price = pizza.price(from: basePrice)
        priceText = format(price: price)
        ingredientsText = pizza.ingredientNames()
        self.onTapPrice = onTapPrice
        self.pizza = pizza
    }

    init() {
        index = 0
        priceText = ""
        ingredientsText = ""
        onTapPrice = { _ in }
        pizza = .init()
    }

    func addToCart() {
        onTapPrice(index)
    }

    @MainActor
    func downloadImage() {
        guard image == nil else { return }
        Task {
            do {
                let image = try await menuModel.dowloadImage(for: pizza)
                DLog(l: .trace, "#> image downloaded for \(pizza.name)")
                self.image = image
            } catch {
                DLog(l: .trace, "#> image download for \(pizza.name) failed: \(error)")
            }
        }
    }
}

extension MenuRowData: Identifiable {
    var id: Int { index }
}
