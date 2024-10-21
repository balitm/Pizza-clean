//
//  CartItemRowData.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain

struct CartItemRowData {
    let name: String
    let priceText: String
    let index: Int
    let id: Int

    init(item: CartItem, index: Int) {
        self.index = index
        name = item.name
        id = item.id
        priceText = format(price: item.price)
    }
}

extension CartItemRowData: Identifiable {}
