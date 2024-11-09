//
//  CartTotalRowData.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation

struct CartTotalRowData {
    var priceText: String

    init(price: Double) {
        priceText = format(price: price)
    }
}
