//
//  PriceFormatter.swift
//  Pizza
//
//  Created by Balázs Kilvády on 2/23/20.
//  Copyright © 2024 kil-dev. All rights reserved.
//

import Foundation

func format(price: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 1
    formatter.minimumFractionDigits = 0

    return "$" + (formatter.string(from: NSNumber(value: price)) ?? "")
}
